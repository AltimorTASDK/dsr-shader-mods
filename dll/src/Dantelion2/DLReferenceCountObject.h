#pragma once

#include <Windows.h>

namespace DLUT {

struct DLReferenceCountObject {
	void **vtable;
	volatile long refcount;

	long Ref()
	{
		return InterlockedIncrement(&refcount);
	}

	long Unref()
	{
		return InterlockedDecrement(&refcount);
	}
};

} // namespace DLUT
