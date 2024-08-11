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

static int build_assert(pTHX_ OP **out, XSParseKeywordPiece *arg0, void *hookdata)
{
    OP *die_op;
    OP *block = arg0->op;

    if (is_strict()) {
        // build the following code:
        //
        //   die "Assertion failed" unless do { $a == 1 }
        //
        die_op = newLISTOP(OP_DIE, 0,
            newOP(OP_PUSHMARK, 0),
            newSVOP(OP_CONST, 0, newSVpv("Assertion failed", 0))
        );

        *out = newLOGOP(OP_AND, 0, newUNOP(OP_NOT, 0, block), die_op);
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
