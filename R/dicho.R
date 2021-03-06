#' @title Dichotomize variables
#' @name dicho
#'
#' @description Dichotomizes variables into dummy variables (0/1). Dichotomization is
#'                either done by median, mean or a specific value (see \code{dich.by}).
#'                Either single vectors, a complete data frame or a list of
#'                variables can be dichotomized.
#'
#' @param x Variable (vector), \code{data.frame} or \code{list} of variables
#'          that should be dichotomized
#' @param dich.by Indicates the split criterion where a variable is dichotomized.
#'          Must be one of the following values (may be abbreviated):
#'          \describe{
#'            \item{\code{"median"} or \code{"md"}}{by default, \code{x} is split into two groups at the median.}
#'            \item{\code{"mean"} or \code{"m"}}{splits \code{x} into two groups at the mean of \code{x}.}
#'            \item{numeric value}{splits \code{x} into two groups at the specific value. Note that the value is inclusive, i.e. \code{dich.by = 10} will split \code{x} into one group with values from lowest to 10 and another group with values greater than 10.}
#'            }
#' @param dich.val Deprecated, use \code{dich.by}.
#' @param as.num Logical, if \code{TRUE}, return value will be numeric, not a factor.
#' @param var.label Optional string, to set variable label attribute for the
#'          dichotomized variable (see \code{\link{set_label}}). If \code{NULL}
#'          (default), variable label attribute of \code{x} will be used (if present).
#' @param val.labels Optional character vector (of length two), to set value label
#'          attributes of dichotomized variable (see \code{\link{set_labels}}).
#'          If \code{NULL} (default), no value labels will be set.
#' @return A dichotomized factor (or numeric, if \code{as.num = TRUE}) variable (0/1-coded),
#'           respectively a data frame or list of dichotomized factor (or numeric) variables.
#'
#' @note Variable label attributes (see, for instance, \code{\link{set_label}}) are preserved
#'         (unless changes via \code{var.label}-argument).
#'
#' @examples
#' data(efc)
#' summary(efc$c12hour)
#' # split at median
#' table(dicho(efc$c12hour))
#' # split at mean
#' table(dicho(efc$c12hour, "mean"))
#' # split between value lowest to 30, and above 30
#' table(dicho(efc$c12hour, 30))
#'
#' # sample data frame, values from 1-4
#' head(efc[, 6:10])
#' # dichtomized values (1 to 2 = 0, 3 to 4 = 1)
#' head(dicho(efc[, 6:10], 2))
#'
#' # dichtomize several variables in a list
#' dummy <- list(efc$c12hour, efc$e17age, efc$c160age)
#' dicho(dummy)
#'
#' # dichotomize and set labels
#' frq(dicho(efc$e42dep, var.label = "Dependency (dichotomized)",
#'           val.labels = c("lower", "higher")))
#'
#' @export
dicho <- function(x,
                  dich.by = "median",
                  dich.val = -1,
                  as.num = FALSE,
                  var.label = NULL,
                  val.labels = NULL) {
  # check deprecated
  if (!missing(dich.val)) {
    .Deprecated("dich.by", old = "dich.val")
    dich.by <- dich.val
  }

  # check for correct dichotome types
  if (!is.numeric(dich.by) && dich.by != "median" && dich.by != "mean" && dich.by != "md" && dich.by != "m") {
    stop("argument `dich.by` must either be `median`, `mean` or a numerical value." , call. = FALSE)
  }

  if (is.matrix(x) || is.data.frame(x) || is.list(x)) {
    # get length of data frame or list, i.e.
    # determine number of variables
    if (is.data.frame(x) || is.matrix(x))
      nvars <- ncol(x)
    else
      nvars <- length(x)

    # dichotomize all
    for (i in 1:nvars) {
      x[[i]] <- dicho_helper(x[[i]], dich.by, as.num, var.label, val.labels)
    }
    return(x)
  } else {
    return(dicho_helper(x, dich.by, as.num, var.label, val.labels))
  }
}


#' @importFrom stats median
dicho_helper <- function(x, dich.by, as.num, var.label, val.labels) {
  # do we have labels? if not, try to
  # automatically get variable labels
  if (is.null(var.label))
    varlab <- get_label(x)
  else
    varlab <- var.label

  # check if factor. factors need conversion
  # to numeric before dichtomizing
  if (is.factor(x)) {
    # non-numeric-factor cannot be converted
    if (is_num_fac(x)) {
      # try to convert to numeric
      x <- as.numeric(as.character(x))
    } else {
      # convert non-numeric factor to numeric
      # factor levels are replaced by numeric values
      x <- to_value(x, keep.labels = FALSE)
      message("Trying to dichotomize non-numeric factor.")
    }
  }
  # split at specific value
  if (is.numeric(dich.by)) {
    x <- ifelse(x <= dich.by, 0, 1)
  } else if (dich.by == "median" || dich.by == "md") {
    x <- ifelse(x <= stats::median(x, na.rm = T), 0, 1)
    # split at mean
  } else if (dich.by == "mean" || dich.by == "m") {
    x <- ifelse(x <= mean(x, na.rm = T), 0, 1)
  }

  if (!as.num) x <- as.factor(x)
  # set back variable labels
  if (!is.null(varlab)) x <- set_label(x, varlab)
  # set value labels
  if (!is.null(val.labels)) x <- set_labels(x, val.labels)
  return(x)
}
