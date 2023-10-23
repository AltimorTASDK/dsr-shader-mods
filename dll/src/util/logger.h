#pragma once

#include <fstream>
#include <format>
#include <source_location>
#include <string>

inline struct {
	std::ofstream file{"dsr-lighting.log"};

	template<typename ...Args>
	void print(std::format_string<Args...> fmt, Args &&...args)
	{
		file << std::format(fmt, std::forward<Args>(args)...) << std::flush;
	}

	template<typename ...Args>
	void println(std::format_string<Args...> fmt, Args &&...args)
	{
		file << std::format(fmt, std::forward<Args>(args)...) << std::endl;
	}
} logger;

inline constexpr std::string base_file_name(const std::source_location &location)
{
	const auto filename = std::string(location.file_name());

	if (const auto pos = filename.rfind('/'); pos != std::string::npos)
		return filename.substr(pos + 1);

	if (const auto pos = filename.rfind('\\'); pos != std::string::npos)
		return filename.substr(pos + 1);

	return filename;
}
