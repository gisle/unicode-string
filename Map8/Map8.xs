/* Copyright (c) 1997, Gisle Aas. */

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "map8.h"

MODULE = Unicode::Map8		PACKAGE = Unicode::Map8   PREFIX=map8_

Map8*
map8_new()
