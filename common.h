#ifndef COMMON_H
#define COMMON_H

// C++ Includes
#include <iostream>
#include <string>
#include <sstream>
#include <cstdint>
#include <exception>
#include <stdexcept>
#include <vector>

// Library includes
#include <curl/curl.h>
#include <curl/easy.h>
#include <sqlite3.h>
#include "pugixml/pugixml.hpp"
#include "uri.h"

// Int types
typedef u_int8_t  u8;
typedef u_int16_t u16;
typedef u_int32_t u32;
typedef u_int64_t u64;

typedef int8_t    i8;
typedef int16_t   i16;
typedef int32_t   i32;
typedef int64_t   i64;

// Defines and more library includes
#define APP_NAME std::string("TKReader")

#if defined __linux__ || defined __MACH__ || defined _APPLE_
#define MKDIR(path) mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH)
#define DATA_FOLDER std::string(std::getenv("HOME")).append("/." + APP_NAME + "/")
#include <tidy.h>
#include <buffio.h>
#include <unistd.h>
#elif defined _WIN32 || defined _WIN64 || defined __CYGWIN__ || __CYGWIN32__
#define MKDIR(path) CreateDirectory(path)
#define DATA_FOLDER std::string(std::getenv("%APPDATA%")).append(APP_NAME + "/")
#include <tidy/tidy.h>
#include <tidy/buffio.h>
#include <windows.h>
#else
#error "System is not supported"
#endif

// Defining Page here, so what? =P
#define ERROR_IMAGE    "qrc:/error.png"

namespace TKReader{

/**
 * Describes a single page from either the archive or the lastet page
 */
struct Page{
    u32 index;
    bool use_local;

    std::string remote_url;
    std::string local_url;

    std::string timestamp;

    static Page GetError(){
        Page error;
        error.remote_url = ERROR_IMAGE;

        return error;
    }
};

} // TKReader

#endif // COMMON_H
