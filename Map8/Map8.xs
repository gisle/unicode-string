/* Copyright 1998 Gisle Aas. */

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

#define map8__new        map8_new
#define map8__new_file   map8_new_file
#define map8__free       map8_free



MODULE = Unicode::Map8		PACKAGE = Unicode::Map8   PREFIX=map8_

PROTOTYPES: DISABLE

Map8*
map8__new()

Map8*
map8__new_file(filename)
	char*filename

void
map8_addpair(map, u8, u16)
	Map8* map
	U8 u8
	U16 u16

void
map8_nostrict(map)
	Map8* map

void
map8__free(map)
	Map8* map

#ifdef DEBUGGING
void
map8_fprint(map, f)
	Map8* map
	FILE* f

#endif

SV*
to8(map, str16)
	Map8* map
	PREINIT:
	    STRLEN len;
	    STRLEN rlen;
	    char* str8;
	INPUT:
	    char* str16 = SvPV(ST(1), len);
	CODE:
	    if (dowarn && (len % 2) != 0)
		warn("Uneven length of wide string");
	    len /= 2;
	    RETVAL = newSV(len + 1);
	    SvPOK_on(RETVAL);
	    str8 = SvPVX(RETVAL);
	    map8_to_str8(map, (U16*)str16, str8, len, &rlen);
	    str8[rlen] = '\0';
	    SvCUR_set(RETVAL, rlen);
	OUTPUT:
	    RETVAL

SV*
to16(map, str8)
	Map8* map
	PREINIT:
	    STRLEN len;
	    STRLEN rlen;
	    char* str16;
	INPUT:
	    char* str8 = SvPV(ST(1), len);
	CODE:
	    RETVAL = newSV(len*2 + 1);
	    SvPOK_on(RETVAL);
	    str16 = SvPVX(RETVAL);
	    map8_to_str16(map, str8, (U16*)str16, len, &rlen);
	    str16[rlen*2] = '\0';
	    SvCUR_set(RETVAL, rlen*2);
	OUTPUT:
	    RETVAL
