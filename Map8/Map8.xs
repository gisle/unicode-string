/* $Id$
 *
 * Copyright 1998, Gisle Aas.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */


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

#define map8__new          map8_new
#define map8__new_txtfile  map8_new_txtfile
#define map8__new_binfile  map8_new_binfile
#define map8__free         map8_free



MODULE = Unicode::Map8		PACKAGE = Unicode::Map8   PREFIX=map8_

PROTOTYPES: DISABLE

Map8*
map8__new()

Map8*
map8__new_txtfile(filename)
	char*filename

Map8*
map8__new_binfile(filename)
	char*filename

void
map8_addpair(map, u8, u16)
	Map8* map
	U8 u8
	U16 u16

U16
map8_default_to8(map,...)
	Map8* map
	ALIAS:
	   default_to16 = 1
	CODE:
	   RETVAL = ix ? map8_get_def_to16(map) : map8_get_def_to8(map);
	   if (items > 1) {
		if (ix)
		    map8_set_def_to16(map, SvIV(ST(1)));
		else
		    map8_set_def_to8(map, SvIV(ST(1)));
	   }
	OUTPUT:
	   RETVAL

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

U16
MAP8_BINFILE_MAGIC_HI()
	CODE:
	    RETVAL = MAP8_BINFILE_MAGIC_HI;
	OUTPUT:
	    RETVAL

U16
MAP8_BINFILE_MAGIC_LO()
	CODE:
	    RETVAL = MAP8_BINFILE_MAGIC_LO;
	OUTPUT:
	    RETVAL

U16
NOCHAR()
	CODE:
	    RETVAL = NOCHAR;
	OUTPUT:
	    RETVAL

SV*
_empty_block(map, block)
	Map8* map
	U8 block
	CODE:
	    if (block > 0xFF)
		croak("Only 256 blocks exists");
	    RETVAL = map8_empty_block(map, block) ? &sv_yes : &sv_no;
	OUTPUT:
	    RETVAL

U16
map8_to_char16(map, c)
	Map8* map
	U8 c
	CODE:
	    RETVAL = ntohs(map8_to_char16(map, c));
	OUTPUT:
	    RETVAL

U16
map8_to_char8(map, uc)
	Map8* map
	U16 uc

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
	    RETVAL = newSV(len*2 + 2);
	    SvPOK_on(RETVAL);
	    str16 = SvPVX(RETVAL);
	    map8_to_str16(map, str8, (U16*)str16, len, &rlen);
	    str16[rlen*2] = '\0';
	    SvCUR_set(RETVAL, rlen*2);
	OUTPUT:
	    RETVAL

SV*
recode8(m1, m2, str)
	Map8* m1
	Map8* m2
	PREINIT:
	    STRLEN len;
	    STRLEN rlen;
	    char*  res;
	INPUT:
	    char* str = SvPV(ST(2), len);
	CODE:
	    RETVAL = newSV(len + 1);
	    SvPOK_on(RETVAL);
	    res = SvPVX(RETVAL);
	    map8_recode8(m1, m2, str, res, len, &rlen);
	    res[rlen] = '\0';
	    SvCUR_set(RETVAL, rlen);
	OUTPUT:
	    RETVAL
