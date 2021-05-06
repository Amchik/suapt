#include <stdio.h>
#include <stdarg.h>

#include "include/printing.h"

#define __CALL_P__ANY(clr, premsg) \
  {\
    va_list args;\
    va_start(args, format);\
    p__any(clr, premsg, format, args);\
    va_end(args);\
  }

void p__any(const char clr, const char* premsg, const char* format, va_list args) {
  printf("[\e[1;%dm%5s\e[0m] ", clr, premsg);
  vprintf(format, args);
  printf("\n");
}

void p_debug(const char* format, ...) __CALL_P__ANY(32, "DEBUG");
void p_info(const char* format, ...) __CALL_P__ANY(34, "INFO");
void p_warn(const char* format, ...) __CALL_P__ANY(33, "WARN");
void p_error(const char* format, ...) __CALL_P__ANY(31, "ERROR");
