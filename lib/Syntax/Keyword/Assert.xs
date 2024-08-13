#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "XSParseKeyword.h"

static bool is_strict(pTHX_)
{
    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    call_pv("Syntax::Keyword::Assert::STRICT", G_SCALAR);
    SPAGAIN;

    bool ok = SvTRUEx(POPs);

    PUTBACK;

    FREETMPS;
    LEAVE;

    return ok;
}

static OP *make_mycroak(pTHX_ OP *msg)
{
    GV *mycroak_gv = gv_fetchpv("Syntax::Keyword::Assert::_croak", GV_ADD, SVt_PVCV);
    OP *mycroak    = newUNOP(OP_NULL, 0, newSVOP(OP_GV, 0, (SV *)mycroak_gv));

    return newUNOP(OP_ENTERSUB, OPf_STACKED, op_append_elem(OP_LIST, msg, mycroak));
}

static int build_assert(pTHX_ OP **out, XSParseKeywordPiece *arg0, void *hookdata)
{
    OP *block = arg0->op;

    if (is_strict()) {
        // build the following code:
        //
        //   Syntax::Keyword::Assert::_croak "Assertion failed"
        //      unless do { $a == 1 }
        //
        OP *msg = newSVOP(OP_CONST, 0, newSVpvs("Assertion failed"));

        // FIXME Attempt to free unreferenced scalar: SV 0x14f7c18c8.

        *out = newLOGOP(OP_AND, 0,
            newUNOP(OP_NOT, 0, block),
            make_mycroak(aTHX_ msg)
        );
    }
    else {
        // do nothing.
        *out = newOP(OP_NULL, 0);
    }

    return KEYWORD_PLUGIN_STMT;
}

static const struct XSParseKeywordHooks hooks_assert = {
  .permit_hintkey = "Syntax::Keyword::Assert/assert",
  .piece1 = XPK_BLOCK,
  .build1 = &build_assert,
};

MODULE = Syntax::Keyword::Assert    PACKAGE = Syntax::Keyword::Assert

BOOT:
  boot_xs_parse_keyword(0.36);
  register_xs_parse_keyword("assert", &hooks_assert, NULL);
