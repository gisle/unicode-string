/*
 * Copyright 2000 Gisle Aas
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static
SV*
encode_utf16(SV* sv)
{
    STRLEN len;
    char *s = SvPV(sv, len);
    SV *ret = newSV(len*2+1);
    char *r = SvPVX(ret);

    if (SvPOK(sv) && SvUTF8(sv)) {
	char *strend = s + len;
	while (s < strend) {
	    I32 utf8_len;
	    UV uv = utf8_to_uv(s, &utf8_len);
	    s += utf8_len;

	    if (uv < 0xD800 || (uv > 0xDFFF && uv <= 0xFFFF)) {
		/* plain 16 bit value */
		*r++ = uv >> 8;
		*r++ = uv;
	    }
	    else if (uv > 0xFFFF && uv <= 0x10FFFF) {
		/* surrogate pair, need 2 bytes extra first */
		char *old_pvx = SvPVX(ret);
		U16 high, low;
		r = SvGROW(ret, SvLEN(sv) + 2) + (r - old_pvx);

		high = uv / 0x400 + 0xD800;
		low  = uv % 0x400 + 0xDC00;

		*r++ = high >> 8;
		*r++ = high;
		*r++ = low >> 8;
		*r++ = low;

	    }
	    else {
		croak("Can't encode char \\x{%04X} in a UTF-16 string", uv);
	    }
	}
    }
    else {
	while (len--) {
	    *r++ = '\0';
	    *r++ = *s++;
	}
    }

    SvPOK_on(ret);
    SvCUR_set(ret, r - SvPVX(ret));
    return ret;
}

static
SV*
decode_utf16(SV* sv)
{
    STRLEN len;
    char *s, *strend, *d;
    SV *ret;
    bool has_utf8 = FALSE;

    if (SvPOK(sv) && !sv_utf8_downgrade(sv, TRUE)) {
	croak("Bad UTF-16 string");
	return &PL_sv_undef;
    }

    s = SvPV(sv, len);
    strend = s + len;

    ret = newSV(len * 3/2 + 1);
    d = SvPVX(ret);
    
    /* borrowed from Larry's Perl_utf16_to_utf8() in utf8.c */
    while (s < strend) {
	UV uv = (U8)*s++ << 8;
	uv += (U8)*s++;

	printf("... %d\n", uv);

	if (uv < 0x80) {
	    *d++ = uv;
	    continue;
	}

	has_utf8 = TRUE;
	if (uv < 0x800) {
	    *d++ = (( uv >>  6)         | 0xc0);
	    *d++ = (( uv        & 0x3f) | 0x80);
	    continue;
	}
	if (uv >= 0xd800 && uv < 0xdbff) {	/* surrogates */
	    /* XXX should check s < strend */
	    UV low = (U8)*s++ << 8;
	    low += (U8)*s++;

	    if (low < 0xdc00 || low >= 0xdfff) {
		croak("Bad surrogate");
	    }
	    uv = ((uv - 0xD800) << 10) + (low - 0xDC00) + 0x10000;
	}
	if (uv < 0x10000) {
	    *d++ = (( uv >> 12)         | 0xe0);
	    *d++ = (((uv >>  6) & 0x3f) | 0x80);
	    *d++ = (( uv        & 0x3f) | 0x80);
	    continue;
	}
	else {
	    *d++ = (( uv >> 18)         | 0xf0);
	    *d++ = (((uv >> 12) & 0x3f) | 0x80);
	    *d++ = (((uv >>  6) & 0x3f) | 0x80);
	    *d++ = (( uv        & 0x3f) | 0x80);
	    continue;
	}
    }

    SvPOK_on(ret);
    SvCUR_set(ret, d - SvPVX(ret));
    if (has_utf8)
	SvUTF8_on(ret);

    return ret;
}


MODULE = Convert::UTF		PACKAGE = Convert::UTF

void
encode_utf8(sv)
    SV* sv
    PPCODE:
        if (GIMME_V == G_VOID) {
            if (SvTHINKFIRST(sv))
		sv_force_normal(sv);
	    sv_utf8_encode(sv);
        }
        else {
	    SV *ret = sv_2mortal(newSVsv(sv));
            sv_utf8_encode(ret);
            PUSHs(ret);
        }

void
decode_utf8(sv)
    SV* sv
    PPCODE:
	if (GIMME_V == G_VOID) {
	    if (SvTHINKFIRST(sv))
		sv_force_normal(sv);
	    sv_utf8_decode(sv);
	}
	else {
	    SV* ret = sv_2mortal(newSVsv(sv));
	    sv_utf8_decode(ret);
	    PUSHs(ret);
        }
	

SV*
is_valid_utf8(sv)
    SV* sv
    PREINIT:
	SV* old_warn = PL_curcop->cop_warnings;
    CODE:
        PL_curcop->cop_warnings = WARN_NONE;  /* suppress utf8 warnings */
	if (sv_utf8_decode(sv)) {
	    SvUTF8_off(sv);                   /* undo any decoding done */
            RETVAL = &PL_sv_yes;
        }
	else {
	    RETVAL = &PL_sv_no;
        }
	PL_curcop->cop_warnings = old_warn;
    OUTPUT:
	RETVAL

SV*
encode_utf16(sv)
    SV* sv
    PPCODE:
        if (GIMME_V == G_VOID) {
	    SV* utf16;
            if (SvTHINKFIRST(sv))
		sv_force_normal(sv);
	    utf16 = encode_utf16(sv);
	    SvTEMP_on(utf16);  /* allow stealing of SvPVX */
	    sv_setsv(sv, utf16);

	    SvREFCNT_dec(utf16);
        }
        else {
            PUSHs(sv_2mortal(encode_utf16(sv)));
        }
	
SV*
decode_utf16(sv)
    SV* sv
    PPCODE:
        if (GIMME_V == G_VOID) {
	    SV* utf8;
            if (SvTHINKFIRST(sv))
		sv_force_normal(sv);
	    utf8 = decode_utf16(sv);
	    SvTEMP_on(utf8);  /* allow stealing of SvPVX */
	    sv_setsv(sv, utf8);

	    SvREFCNT_dec(utf8);
        }
        else {
            PUSHs(sv_2mortal(decode_utf16(sv)));
        }
