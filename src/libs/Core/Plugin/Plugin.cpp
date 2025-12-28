#include "Plugin.h"

#ifdef _WIN32
#  include <Windows.h>
#else
#  include <dlfcn.h>
#endif

namespace binop {

    static std::wstring getFullModuleFilePath(HMODULE hModule) {
        // https://stackoverflow.com/a/57114164/17177007
        DWORD size = MAX_PATH;
        std::wstring buffer;
        buffer.resize(size);
        while (true) {
            DWORD result = ::GetModuleFileNameW(hModule, buffer.data(), size);
            if (result == 0) {
                break;
            }

            if (result < size) {
                buffer.resize(result);
                return buffer;
            }

            // Check if a larger buffer is needed
            if (::GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
                size *= 2;
                buffer.resize(size);
                continue;
            }

            // Exactly
            return buffer;
        }
        return {};
    }

    std::filesystem::path Plugin::path() const {
#ifdef _WIN32
        HMODULE hModule = nullptr;
        if (!::GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                                      GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                                  (LPCWSTR) this, &hModule)) {
            return {};
        }
        return getFullModuleFilePath(hModule);
#else
        Dl_info dl_info;
        dladdr(const_cast<void *>(addr), &dl_info);
        auto buf = dl_info.dli_fname;
        return buf;
#endif
    }

}