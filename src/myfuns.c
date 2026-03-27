/* Standard R headers ---------------------------------------- */
#define STRICT_R_HEADERS
#include <R.h>
#include <Rinternals.h>
#include <R_ext/RS.h>

/* ============================================================
   Scalar functions (used by rxode2 ODE solver)
   ============================================================ */

/* mm(C, Vmax, Km) = Vmax*C / (Km+C) */
double mm(double C, double Vmax, double Km) {
  return Vmax * C / (Km + C);
}

/* d(mm)/dC   = Vmax*Km / (Km+C)^2 */
double mm_dC(double C, double Vmax, double Km) {
  double den = Km + C;
  return Vmax * Km / (den * den);
}

/* d(mm)/dVmax = C / (Km+C) */
double mm_dVmax(double C, double Vmax, double Km) {
  (void)Vmax;
  return C / (Km + C);
}

/* d(mm)/dKm  = -Vmax*C / (Km+C)^2 */
double mm_dKm(double C, double Vmax, double Km) {
  double den = Km + C;
  return -Vmax * C / (den * den);
}

/* ============================================================
   SEXP vector wrappers (called from R via .Call)
   Assumes C, Vmax, Km are REALSXP vectors of the same length
   (enforce equal length via data.frame() in the R interface).
   ============================================================ */

SEXP _mm_mm(SEXP C, SEXP Vmax, SEXP Km) {
  int n = LENGTH(C);
  SEXP out = PROTECT(allocVector(REALSXP, n));
  double *c = REAL(C), *vmax = REAL(Vmax), *km = REAL(Km);
  double *res = REAL(out);
  for (int i = 0; i < n; i++) res[i] = mm(c[i], vmax[i], km[i]);
  UNPROTECT(1);
  return out;
}

SEXP _mm_mm_dC(SEXP C, SEXP Vmax, SEXP Km) {
  int n = LENGTH(C);
  SEXP out = PROTECT(allocVector(REALSXP, n));
  double *c = REAL(C), *vmax = REAL(Vmax), *km = REAL(Km);
  double *res = REAL(out);
  for (int i = 0; i < n; i++) res[i] = mm_dC(c[i], vmax[i], km[i]);
  UNPROTECT(1);
  return out;
}

SEXP _mm_mm_dVmax(SEXP C, SEXP Vmax, SEXP Km) {
  int n = LENGTH(C);
  SEXP out = PROTECT(allocVector(REALSXP, n));
  double *c = REAL(C), *vmax = REAL(Vmax), *km = REAL(Km);
  double *res = REAL(out);
  for (int i = 0; i < n; i++) res[i] = mm_dVmax(c[i], vmax[i], km[i]);
  UNPROTECT(1);
  return out;
}

SEXP _mm_mm_dKm(SEXP C, SEXP Vmax, SEXP Km) {
  int n = LENGTH(C);
  SEXP out = PROTECT(allocVector(REALSXP, n));
  double *c = REAL(C), *vmax = REAL(Vmax), *km = REAL(Km);
  double *res = REAL(out);
  for (int i = 0; i < n; i++) res[i] = mm_dKm(c[i], vmax[i], km[i]);
  UNPROTECT(1);
  return out;
}
