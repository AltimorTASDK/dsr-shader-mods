import argparse
import os
import sentinel
import struct
import sys

class BinaryReader():
    DefaultEncoding = sentinel.create()

    def __init__(self, buffer: bytes, *,
                 offset=0, encoding: str | None='utf-8'):
        self._buffer = buffer
        self._offset = offset
        self._encoding = encoding

    def data(self):
        return self._buffer

    def seek(self, offset: int):
        self._offset = offset

    def skip(self, count: int):
        self._offset += count

    def tell(self) -> int:
        return self._offset

    def unpack(self, format: str | bytes):
        results = struct.unpack_from(format, self._buffer, self._offset)
        self._offset += struct.calcsize(format)
        return results

    def _read_primitive(self, format: str | bytes, count: int | None=None):
        if count is None:
            return self.unpack(format)[0]
        else:
            assert count >= 0
            return self.unpack(f"{count}{format}") if count != 0 else []

    def bool(self, count: int | None=None) -> bool | tuple[bool, ...]:
        return self._read_primitive('?', count)

    def s8(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('b', count)

    def u8(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('B', count)

    def s16(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('h', count)

    def u16(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('H', count)

    def s32(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('i', count)

    def u32(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('I', count)

    def s64(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('q', count)

    def u64(self, count: int | None=None) -> int | tuple[int, ...]:
        return self._read_primitive('Q', count)

    def f32(self, count: int | None=None) -> float | tuple[float, ...]:
        return self._read_primitive('f', count)

    def f64(self, count: int | None=None) -> float | tuple[float, ...]:
        return self._read_primitive('d', count)

    def read(self, count: int) -> bytes:
        result = self._buffer[self._offset:self._offset+count]
        self._offset += count
        return result

    def string(self, size: int | None=None, *,
               encoding: str | None=DefaultEncoding) -> str | bytes:
        """Read a fixed length or null terminated string"""
        if encoding is BinaryReader.DefaultEncoding:
            encoding = self._encoding

        if size is None:
            # Null terminated
            size = self._buffer.index(b"\0", self._offset) - self._offset + 1

        result = self.read(size).rstrip(b"\0")
        return result if encoding is None else result.decode(encoding)

class PDBStream:
    name: str | None

    def __init__(self, reader: BinaryReader):
        self.data = reader.data()
        self.reader = reader
        self.name = None

class SPDB:
    def __init__(self, data: bytes):
        self.data = data
        reader = BinaryReader(data)
        identifier = reader.string(32)
        self.page_size = reader.u32()
        free_page_map_idx = reader.u32()
        page_count = reader.u32()
        directory_size = reader.u32()
        reserved = reader.u32()
        directory = self._map_page_table(reader, directory_size, depth=2)

        stream_count = directory.u32()
        stream_sizes = directory.u32(stream_count)

        self.streams = [PDBStream(self._map_page_table(directory, size))
                        for size in stream_sizes]

        self._read_stream_names(self.streams[1].reader)

    def _read_stream_names(self, reader: BinaryReader):
        version = reader.u32()
        signature = reader.u32()
        age = reader.u32()
        guid = reader.read(16)
        name_table_size = reader.u32()
        name_table = BinaryReader(reader.read(name_table_size))

        bitmap_popcnt = reader.u32()
        bitmap_size = reader.u32()
        bitmap_words = reader.u32()
        bitmap = reader.u32(bitmap_words)
        reserved = reader.u32()

        for bit in range(bitmap_size):
            if bitmap[bit // 32] & (1 << (bit % 32)):
                name_offset = reader.u32()
                stream_index = reader.u32()
                name_table.seek(name_offset)
                self.streams[stream_index].name = name_table.string()

    def _to_page_count(self, size: int):
        return (size + self.page_size - 1) // self.page_size

    def _map_pages(self, pages: list[int],
                  map_size: int | None=None) -> BinaryReader:
        """Copy pages into contiguous buffer"""
        if map_size is None:
            map_size = len(pages) * self.page_size

        assert self._to_page_count(map_size) == len(pages)
        buffer = bytearray(map_size)

        for index, page in enumerate(pages):
            dst = index * self.page_size
            src = page * self.page_size
            size = min(self.page_size, map_size - dst)
            buffer[dst:dst+size] = self.data[src:src+size]

        return BinaryReader(buffer)

    def _map_page_table(self, table: BinaryReader, map_size: int, *,
                        depth=1) -> BinaryReader:
        if depth > 1:
            # Multi-level page table
            table_size = self._to_page_count(map_size) * 4
            table = self._map_page_table(table, table_size, depth=depth - 1)

        indices = table.u32(self._to_page_count(map_size))
        return self._map_pages(indices, map_size)

    def dump_files(self, out_directory: str, base_directory: str):
        os.makedirs(out_directory, mode=0o777, exist_ok=True)
        base_directory = os.path.splitdrive(base_directory)[1]

        for stream in self.streams:
            if stream.name is None:
                continue

            if not stream.name.startswith("/src/files/"):
                continue

            source_path = stream.name[len("/src/files/"):]
            base_path = os.path.splitdrive(source_path.replace("\\", "/"))[1]

            if base_directory is None:
                base_path = os.path.basename(base_path)
            else:
                base_path = os.path.relpath(base_path, base_directory)

            path = os.path.join(out_directory, os.path.normpath(base_path))

            if os.path.exists(path):
                with open(path, "rb") as input:
                    if input.read() == stream.data:
                        print(f"{base_path} already exists (Identical)")
                    else:
                        print(f"{base_path} already exists (Different)")
                continue

            print(f"Extracting {base_path}")
            os.makedirs(os.path.dirname(path), mode=0o777, exist_ok=True)

            with open(path, "wb") as output:
                output.write(stream.data)

def dump_shader(data: bytes, out_directory: str, base_directory: str):
    reader = BinaryReader(data)

    if reader.read(4) != b"DXBC":
        raise ValueError("Not a valid DXBC shader")

    hash_value = reader.read(16)
    container_version = reader.u32()
    file_length = reader.u32()
    chunk_count = reader.u32()
    chunk_offsets = reader.u32(chunk_count)

    for offset in chunk_offsets:
        reader.seek(offset)
        if reader.read(4) == b"SPDB":
            spdb = SPDB(reader.read(reader.u32()))
            spdb.dump_files(out_directory, base_directory)
            return True

    return False

def main():
    parser = argparse.ArgumentParser(
        prog="hlsldump",
        description="Extracts source code from shader SPDB chunks")

    parser.add_argument("shader", type=argparse.FileType("rb"))
    parser.add_argument("-b", "--basedir", type=str)
    parser.add_argument("-o", "--outdir", type=str, default=".")
    args = parser.parse_args()

    if not dump_shader(args.shader.read(), args.outdir, args.basedir):
        print("No PDB info", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()