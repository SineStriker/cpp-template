#ifndef BINOP_GUI_GLOBAL_H
#define BINOP_GUI_GLOBAL_H

#include <binop/Core/Global.h>

#ifndef BINOP_GUI_EXPORT
#  ifdef BINOP_GUI_STATIC
#    define BINOP_GUI_EXPORT
#  else
#    ifdef BINOP_GUI_LIBRARY
#      define BINOP_GUI_EXPORT BINOP_CORE_DECL_EXPORT
#    else
#      define BINOP_GUI_EXPORT BINOP_CORE_DECL_IMPORT
#    endif
#  endif
#endif

#endif // BINOP_GUI_GLOBAL_H
