.onAttach <- function(libname, pkgname) {
  .cur <- rxode2::rxode2parseGetTranslation()

  .newRows <- data.frame(
    rxFun      = c("mm",         "mm_dC",      "mm_dVmax",   "mm_dKm"),
    fun        = c("mm",         "mm_dC",      "mm_dVmax",   "mm_dKm"),
    type       = rep("rxode2_fn3", 4),
    package    = rep("mm", 4),
    packageFun = c("mm",         "mm_dC",      "mm_dVmax",   "mm_dKm"),
    argMin     = 3L,
    argMax     = 3L,
    threadSafe = 1L,
    stringsAsFactors = FALSE
  )

  ## Check for name conflicts before modifying the table.
  .mmNames   <- .newRows$rxFun
  .conflicts <- .cur[.cur$rxFun %in% .mmNames, , drop = FALSE]

  if (nrow(.conflicts) > 0L) {
    .fromOther <- .conflicts[.conflicts$package != "mm", , drop = FALSE]
    .fromSelf  <- .conflicts[.conflicts$package == "mm", , drop = FALSE]

    if (nrow(.fromOther) > 0L) {
      stop(
        "Cannot load package 'mm': the following rxode2 function name(s) are ",
        "already registered by another package:\n",
        paste0("  ", .fromOther$rxFun, " (registered by '",
               .fromOther$package, "')", collapse = "\n"),
        call. = FALSE
      )
    }

    if (nrow(.fromSelf) > 0L) {
      packageStartupMessage(
        "Package 'mm' rxode2 function registration was already present ",
        "(package reloaded); re-registering."
      )
    }
  }

  ## Remove any existing mm rows (covers the reload case) then add fresh ones.
  .cur <- .cur[.cur$package != "mm", , drop = FALSE]
  rxode2::rxode2parseAssignTranslation(rbind(.cur, .newRows))

  ## Register first-order derivatives, referencing the C functions directly.
  rxode2::rxD("mm", list(
    function(C, Vmax, Km) paste0("mm_dC(",    C, ",", Vmax, ",", Km, ")"),
    function(C, Vmax, Km) paste0("mm_dVmax(", C, ",", Vmax, ",", Km, ")"),
    function(C, Vmax, Km) paste0("mm_dKm(",   C, ",", Vmax, ",", Km, ")")
  ))

  ## Register second-order derivatives as inline C expressions.
  ##
  ## mm_dC = Vmax*Km/(Km+C)^2
  ##   d/dC    = -2*Vmax*Km / (Km+C)^3
  ##   d/dVmax =    Km      / (Km+C)^2
  ##   d/dKm   =  Vmax*(C-Km) / (Km+C)^3
  rxode2::rxD("mm_dC", list(
    function(C, Vmax, Km)
      paste0("(-2.0*(", Vmax, ")*(", Km, "))/pow((", Km, ")+(", C, "),3.0)"),
    function(C, Vmax, Km)
      paste0("(", Km, ")/pow((", Km, ")+(", C, "),2.0)"),
    function(C, Vmax, Km)
      paste0("(", Vmax, ")*((", C, ")-(", Km, "))/pow((", Km, ")+(", C, "),3.0)")
  ))

  ## mm_dVmax = C/(Km+C)
  ##   d/dC    =  Km / (Km+C)^2
  ##   d/dVmax =  0
  ##   d/dKm   = -C  / (Km+C)^2
  rxode2::rxD("mm_dVmax", list(
    function(C, Vmax, Km)
      paste0("(", Km, ")/pow((", Km, ")+(", C, "),2.0)"),
    function(C, Vmax, Km) "0.0",
    function(C, Vmax, Km)
      paste0("-(", C, ")/pow((", Km, ")+(", C, "),2.0)")
  ))

  ## mm_dKm = -Vmax*C/(Km+C)^2
  ##   d/dC    =  Vmax*(C-Km) / (Km+C)^3
  ##   d/dVmax = -C           / (Km+C)^2
  ##   d/dKm   =  2*Vmax*C   / (Km+C)^3
  rxode2::rxD("mm_dKm", list(
    function(C, Vmax, Km)
      paste0("(", Vmax, ")*((", C, ")-(", Km, "))/pow((", Km, ")+(", C, "),3.0)"),
    function(C, Vmax, Km)
      paste0("-(", C, ")/pow((", Km, ")+(", C, "),2.0)"),
    function(C, Vmax, Km)
      paste0("2.0*(", Vmax, ")*(", C, ")/pow((", Km, ")+(", C, "),3.0)")
  ))

  invisible()
}

.onUnload <- function(libpath) {
  ## Remove only this package's rows from the translation table.
  ## Filtering by package == "mm" is safe when multiple packages have
  ## each added their own rows: other packages' entries are untouched.
  .cur <- try(rxode2::rxode2parseGetTranslation(), silent = TRUE)
  if (!inherits(.cur, "try-error")) {
    try(rxode2::rxode2parseAssignTranslation(
      .cur[.cur$package != "mm", , drop = FALSE]
    ), silent = TRUE)
  }
  ## Remove derivative entries for all registered function names.
  try(rxode2::rxRmFun("mm"),       silent = TRUE)
  try(rxode2::rxRmFun("mm_dC"),    silent = TRUE)
  try(rxode2::rxRmFun("mm_dVmax"), silent = TRUE)
  try(rxode2::rxRmFun("mm_dKm"),   silent = TRUE)
}
