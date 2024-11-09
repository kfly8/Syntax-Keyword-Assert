#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "XSParseKeyword.h"

#define HAVE_PERL_VERSION(R, V, S) \
    (PERL_REVISION > (R) || (PERL_REVISION == (R) && (PERL_VERSION > (V) || (PERL_VERSION == (V) && (PERL_SUBVERSION >= (S))))))

#include "newUNOP_CUSTOM.c.inc"

static bool assert_enabled = TRUE;

static XOP xop_assert;
static OP *pp_assert(pTHX)
{
  dSP;
  SV *val = POPs;

  if(SvTRUE(val))
    RETURN;

  SV *msg = sv_2mortal(newSVpvs("Assertion failed"));
  croak_sv(msg);
}

static int build_assert(pTHX_ OP **out, XSParseKeywordPiece *arg0, void *hookdata)
{
    OP *argop = arg0->op;
    if (assert_enabled) {
        *out = newUNOP_CUSTOM(&pp_assert, 0, argop);
    }
    else {
        // do nothing.
        op_free(argop);
        *out = newOP(OP_NULL, 0);
    }

    return KEYWORD_PLUGIN_EXPR;
}

static const struct XSParseKeywordHooks hooks_assert = {
  .permit_hintkey = "Syntax::Keyword::Assert/assert",
  .piece1 = XPK_TERMEXPR_SCALARCTX,
  .build1 = &build_assert,
};

MODULE = Syntax::Keyword::Assert    PACKAGE = Syntax::Keyword::Assert

BOOT:
  boot_xs_parse_keyword(0.36);

  XopENTRY_set(&xop_assert, xop_name, "assert");
  XopENTRY_set(&xop_assert, xop_desc, "assert");
  XopENTRY_set(&xop_assert, xop_class, OA_UNOP);
  Perl_custom_op_register(aTHX_ &pp_assert, &xop_assert);

  register_xs_parse_keyword("assert", &hooks_assert, NULL);

  {
    const char *enabledstr = getenv("PERL_ASSERT_ENABLED");
    if(enabledstr) {
      SV *sv = newSVpvn(enabledstr, strlen(enabledstr));
      if(!SvTRUE(sv))
        assert_enabled = FALSE;
    }
  }

