# sjmisc 1.8.0-3

## General

* **sjmisc** now supports _tagged_ `NA` values, a new structue for labelled missing values introduced by the [haven-package](https://cran.r-project.org/package=haven). This means that functions or arguments that are no longer useful, have been removed while other functions dealing with NA values have been largely revised.
* All statistical functions have been removed and are now in a separate package, [sjstats](https://cran.r-project.org/package=sjstats).
* Removed some S3-methods for `labelled`-class, as these are now provided by the haven-package.

## Changes to functions

* `zap_na_tags` to turn tagged `NA` values into regular `NA` values.
* `str_contains` gets a `switch` argument to switch the role of `x` and `pattern`.

## New functions

* Added `to_character` method.

## Bug fixes

* `is_empty` returned `NA` instead of `TRUE` for empty character vectors.
* Fixed bug with erroneous assignment of value labels to subset data when using `copy_labels` ([#20](https://github.com/sjPlot/sjmisc/issues/20))
