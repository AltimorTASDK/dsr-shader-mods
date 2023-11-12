#pragma once

#include <cstddef>
#include <new>
#include <utility>

namespace DLKRD {

struct HeapAllocator {
	char pad008[0x20 - 0x08];

	virtual void vfunc000() = 0;
	virtual void vfunc001() = 0;
	virtual void vfunc002() = 0;
	virtual void vfunc003() = 0;
	virtual void vfunc004() = 0;
	virtual void vfunc005() = 0;
	virtual void vfunc006() = 0;
	virtual void vfunc007() = 0;
	virtual void vfunc008() = 0;
	virtual void vfunc009() = 0;
	virtual void *MemAlign(size_t size, size_t align) = 0;

	template<typename T>
	T *New(auto &&...args)
	{
		T *object = (T*)MemAlign(sizeof(T), alignof(T));
		new (object) T(std::forward<decltype(args)>(args)...);
		return object;
	};
};

} // namespace DLKRD
