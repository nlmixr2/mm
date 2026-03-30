#' Michaelis-Menten saturable elimination
#'
#' Computes \eqn{V_{\max} \cdot C / (K_m + C)} element-wise over
#' equal-length (or recyclable) numeric vectors.
#'
#' Also registers the function and its first- and second-order analytic
#' derivatives with \pkg{rxode2} so that \code{mm()} can be used directly
#' inside \code{rxode2} and \code{nlmixr2} models, including gradient-based
#' estimation.
#'
#' @param C Numeric vector of concentrations.
#' @param Vmax Numeric vector of maximum elimination rates.
#' @param Km Numeric vector of Michaelis constants.
#' @return Numeric vector of elimination rates, the same length as the
#'   recycled inputs.
#' @export
#' @useDynLib mm, .registration = TRUE
#' @importFrom rxode2 rxD rxode2parseAssignTranslation rxode2parseGetTranslation
mm <- function(C, Vmax, Km) {
  df <- data.frame(C = C, Vmax = Vmax, Km = Km)
  .Call(`_mm_mm`, as.double(df$C), as.double(df$Vmax), as.double(df$Km))
}

#' @describeIn mm Partial derivative with respect to C
#' @export
mm_dC <- function(C, Vmax, Km) {
  df <- data.frame(C = C, Vmax = Vmax, Km = Km)
  .Call(`_mm_mm_dC`, as.double(df$C), as.double(df$Vmax), as.double(df$Km))
}

#' @describeIn mm Partial derivative with respect to Vmax
#' @export
mm_dVmax <- function(C, Vmax, Km) {
  df <- data.frame(C = C, Vmax = Vmax, Km = Km)
  .Call(`_mm_mm_dVmax`, as.double(df$C), as.double(df$Vmax), as.double(df$Km))
}

#' @describeIn mm Partial derivative with respect to Km
#' @export
mm_dKm <- function(C, Vmax, Km) {
  df <- data.frame(C = C, Vmax = Vmax, Km = Km)
  .Call(`_mm_mm_dKm`, as.double(df$C), as.double(df$Vmax), as.double(df$Km))
}

#' @importFrom rxode2 rxUdfUi
#' @export
rxode2::rxUdfUi

#' rxode2 ui model interface for mm()
#'
#' Allows \code{mm()} to be called with named arguments in any order
#' inside \code{rxode2}/\code{nlmixr2} ui models, e.g.
#' \code{mm(Km=Km, C=Cp, Vmax=Vmax)}.  The method rewrites the call
#' to the canonical positional form \code{mm(C, Vmax, Km)} before the
#' model is compiled.
#'
#' @param fun Quoted language object representing the \code{mm()} call
#'   as it appears in the model.
#' @return A list with element \code{$replace}: the rewritten call as
#'   a character string.
#' @export
rxUdfUi.mm <- function(fun) {
  # Use a dummy function with the canonical argument order so that
  # match.call() can map any combination of named / positional
  # arguments back to the C-level positional order.
  .dummy <- function(C, Vmax, Km) {}
  .mc <- match.call(.dummy, fun)

  .C    <- deparse1(.mc$C)
  .Vmax <- deparse1(.mc$Vmax)
  .Km   <- deparse1(.mc$Km)

  list(replace = paste0("mm(", .C, ",", .Vmax, ",", .Km, ")"))
}
