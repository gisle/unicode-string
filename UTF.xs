/*
 * Copyright 2000 Gisle Aas
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

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
