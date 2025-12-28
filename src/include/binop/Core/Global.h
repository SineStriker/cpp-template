#ifndef BINOP_CORE_COREGLOBAL_H
#define BINOP_CORE_COREGLOBAL_H

#ifdef _WIN32
#  define BINOP_CORE_DECL_EXPORT __declspec(dllexport)
#  define BINOP_CORE_DECL_IMPORT __declspec(dllimport)
#else
#  define BINOP_CORE_DECL_EXPORT __attribute__((visibility("default")))
#  define BINOP_CORE_DECL_IMPORT __attribute__((visibility("default")))
#endif

#ifndef BINOP_CORE_EXPORT
#  ifdef BINOP_CORE_STATIC
#    define BINOP_CORE_EXPORT
#  else
#    ifdef BINOP_CORE_LIBRARY
#      define BINOP_CORE_EXPORT BINOP_CORE_DECL_EXPORT
#    else
#      define BINOP_CORE_EXPORT BINOP_CORE_DECL_IMPORT
#    endif
#  endif
#endif

#endif // BINOP_CORE_COREGLOBAL_H
