#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <stdlib.h>   /* NULL */

/* Forward-declare scalar functions from myfuns.c */
extern double mm      (double, double, double);
extern double mm_dC   (double, double, double);
extern double mm_dVmax(double, double, double);
extern double mm_dKm  (double, double, double);

/* Forward-declare SEXP wrappers from myfuns.c */
extern SEXP _mm_mm      (SEXP, SEXP, SEXP);
extern SEXP _mm_mm_dC   (SEXP, SEXP, SEXP);
extern SEXP _mm_mm_dVmax(SEXP, SEXP, SEXP);
extern SEXP _mm_mm_dKm  (SEXP, SEXP, SEXP);

void R_init_mm(DllInfo *dll) {

  /* --- .Call registration -----------------------------------
     Makes SEXP wrappers available to .Call() from R.          */
  static const R_CallMethodDef callMethods[] = {
    {"_mm_mm",       (DL_FUNC) &_mm_mm,       3},
    {"_mm_mm_dC",    (DL_FUNC) &_mm_mm_dC,    3},
    {"_mm_mm_dVmax", (DL_FUNC) &_mm_mm_dVmax, 3},
    {"_mm_mm_dKm",   (DL_FUNC) &_mm_mm_dKm,  3},
    {NULL, NULL, 0}
  };
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);

  /* --- R_RegisterCCallable ----------------------------------
     REQUIRED for rxode2 integration.  Makes each scalar symbol
     retrievable from other packages' C code via
     R_GetCCallable("mm", "<name>").
     rxode2's generated model C files use exactly this.        */
  R_RegisterCCallable("mm", "mm",       (DL_FUNC) &mm);
  R_RegisterCCallable("mm", "mm_dC",    (DL_FUNC) &mm_dC);
  R_RegisterCCallable("mm", "mm_dVmax", (DL_FUNC) &mm_dVmax);
  R_RegisterCCallable("mm", "mm_dKm",   (DL_FUNC) &mm_dKm);
}
