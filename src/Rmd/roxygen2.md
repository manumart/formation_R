<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Generating Rd files}
-->

<!--
Rscript -e 'require(knitr); knit("roxygen2.Rmd")'; cp roxygen2.md ../markdown/; cd ../markdown/; make roxygen2.md.slides.pdf; cd ../Rmd
-->





---

La documentation roxygen a deux fonctions : 

1. Elle vous aide à structurer la documentation de vos fonctions et de vos jeux de donneés
2. Elle permet de générer automatiquement les différents supports de documentation fournis avec les packages R

---

## Générer les fichiers Rd
* Les fichiers Rd sont dans un format simple dérivé de Latex

* Lorsque vous utilisez `? X`,` help ("x") `ou` example ("x") `R recherche un fichier Rd contenant` \ alias {x} `. Il analyse ensuite le fichier, le convertit en html et l'affiche.

* Ils font partie de la documentation des packages R

---


 * [treeOut.txt](./treeOut.txt)
 * [R](./R)
	* [functions.r](./R/functions.r)
 * [DESCRIPTION](./DESCRIPTION)
 * [tests](./tests)
	* [testthat](./tests/testthat)
		* [test-exemple.r](./tests/testthat/test-exemple.r)
	* [testthat.R](./tests/testthat.R)
 * [man](./man)
	* **[add.Rd](./man/add.Rd)**
 * [vignettes](./vignettes)
	* [formationR.Rnw](./vignettes/formationR.Rnw)
 * [data](./data)
 * [NAMESPACE](./NAMESPACE)

---


## Le processus Roxygen

Ce processu se décompose en trois étapes:

1. Ajouter des commentaires suivant la syntaxe roxygen aux fichiers source.
2. `roxygen2::roxygenise()` convertit les commentaires roxygen en fichiers `.Rd`.
3. R convertit les fichiers `.Rd` en documentaion lisible par chacune et chacun.

Les commentaires roxygen commencent par `#'`, et les autres commentaires peuvent toujours être utilisés.

--- 

## Un exemple

```r
#' Add together two numbers
#'
#' @param x A number
#' @param y A number
#' @return The sum of \code{x} and \code{y}
#' @examples
#' add(1, 1)
#' add(10, 1)
add <- function(x, y) {
  x + y
}
```

---

## Eléments de base

Roxygen comments start with `#'` and include tags like `@tag details`. Tags break the documentation up into pieces, and the content of a tag extends from the end of tag name to the start of the next tag (or the end of the block). Because `@` has a special meaning in roxygen, you need to write `@@` to add a literal `@` to the documentation.

Each documentation block starts with some text. The first sentence becomes the title of the documentation. That's what you see when you look at `help(package = mypackage)` and is shown at the top of each help file. It should fit on one line, be written in sentence case, and end in a full stop. The second paragraph is the description: this comes first in the documentation and should briefly describe what the function does. The third and subsequent paragraphs go into the details: this is a (often long) section that comes after the argument description and should provide any other important details of how the function operates.

Here's an example showing what the documentation for `sum()` might look like if it had been written with roxygen:


```r
#' Sum of vector elements.
#'
#' \code{sum} returns the sum of all the values present in its arguments.
#'
#' This is a generic function: methods can be defined for it directly
#' or via the \code{\link{Summary}} group generic. For this to work properly,
#' the arguments \code{...} should be unnamed, and dispatch is on the
#' first argument.
sum <- function(..., na.rm = TRUE) {}
```


---

`\code{}` and `\link{}` are `.Rd` formatting commands which you'll learn more about in [formatting](formatting.html). Also notice the wrapping of the roxygen block. You should make sure that your comments are less than ~80 columns wide.

The following documentation produces the same help file as above, but uses explicit tags. You only need explicit tags if you want to the title or description to span multiple paragraphs (a bad idea), or want to omit the description (in which case roxygen will use the title for the description, since it's a required documentation component).


```r
#' @title Sum of vector elements.
#'
#' @description
#' \code{sum} returns the sum of all the values present in its arguments.
#'
#' @details
#' This is a generic function: methods can be defined for it directly
#' or via the \code{\link{Summary}} group generic. For this to work properly,
#' the arguments \code{...} should be unnamed, and dispatch is on the
#' first argument.
sum <- function(..., na.rm = TRUE) {}
```


All objects must have a title and description. Details are optional.

### Enhancing navigation.

There are two tags that make it easier for people to navigate around your documentation: `@seealso` and `@family`. 

`@seealso` allows you to point to other useful resources, either on the web `\url{http://www.r-project.org}`, or to other documentation with `\code{\link{functioname}}`. 

If you have a family of related functions, you can use the `@family <family>` tag to automatically add appropriate lists and interlinks to the `@seealso` section. Because it will appear as "Other <family>:", the `@family` name should be plural (i.e., "model building helpers" not "model building helper"). You can make a function a member of multiple families by repeating the @family tag for each additional family. These will then get seaprate headings in the __seealso__ section.

For sum, these components might look like:


```r
#' @family aggregate functions
#' @seealso \code{\link{prod}} for products, \code{\link{cumsum}} for
#'  cumulative sums, and \code{\link{colSums}}/\code{\link{rowSums}}
#'  marginal sums over high-dimensional arrays.
```


Three other tags make it easier for the user to find documentation:

* `@aliases space separated aliases` to add additional aliases, through
  which the user can find the documentation with `?`.

* `@concept` to add extra keywords that will be found with `help.search()`

* `@keywords keyword1 keyword2 ...` to add standardised keywords. Keywords are
  optional, but if present, must be taken from the predefined list replicated
  in the [keywords vignette](rdkeywords.html). Keywords are not very useful,
  except for `@keywords internal`. Using the internal keyword removes all functions
  in the associated `.Rd` file from the documentation index and disables some of
  their automated tests.
  A common use case is to both export a function (using `@export`) and marking it as
  internal. That way, advanced users can access a function that new users would be confused
  about if they were to see it in the index.

You use other tags based on the type of object that you're documenting. The following sections describe the most commonly used tags for functions, S3, S4 and RC objects and data.

## Documenting functions

Functions are the mostly commonly documented objects. Most functions use three tags:

*   `@param name description` describes the inputs to the function.
    The description should provide a succinct summary of the type of the
    parameter (e.g. a string, a numeric vector), and if not obvious from
    the name, what the parameter does. The description should start with a
    capital letter and end with a full stop. It can span multiple lines (or
    even paragraphs) if necessary. All parameters must be documented.

    You can document multiple arguments in one place by separating
    the names with commas (no spaces). For example, to document both
    `x` and `y`, you can say `@param x,y Numeric vectors`.

*   `@examples` provides executable R code showing how to use the function in
    practice. This is a very important part of the documentation because
    many people look at the examples before reading anything. Example code
    must work without errors as it is run automatically as part of `R CMD
    check`.

    However for the purpose of illustration, it's often useful to include code
    that causes an error. `\dontrun{}` allows you to include code in the
    example that is never used. There are two other special commands.
    `\dontshow{}` is run, but not shown in the help page: this can
    be useful for informal tests. `\donttest{}` is run in examples,
    but not run automatically in `R CMD check`. This is useful if you
    have examples that take a long time to run. The options are summarised
    below.

    Command      | example   | help   | R CMD check
    ------------ | --------- | ------ | -----------
    `\dontrun{}` |           | x      |
    `\dontshow{}`| x         |        | x
    `\donttest{}`| x         | x      |

    Instead of including examples directly in the documentation, you can
    put them in separate files and use `@example path/relative/to/packge/root`
    to insert them into the documentation.

*   `@return description` describes the output from the function. This is
    not always necessary, but is a good idea if you return different types
    of outputs depending on the input, or you're returning an S3, S4 or RC
    object.

We could use these new tags to improve our documentation of `sum()` as follows:


```r
#' Sum of vector elements.
#'
#' \code{sum} returns the sum of all the values present in its arguments.
#'
#' This is a generic function: methods can be defined for it directly
#' or via the \code{\link{Summary}} group generic. For this to work properly,
#' the arguments \code{...} should be unnamed, and dispatch is on the
#' first argument.
#'
#' @param ... Numeric, complex, or logical vectors.
#' @param na.rm A logical scalar. Should missing values (including NaN)
#'   be removed?
#' @return If all inputs are integer and logical, then the output
#'   will be an integer. If integer overflow
#'   \url{http://en.wikipedia.org/wiki/Integer_overflow} occurs, the output
#'   will be NA with a warning. Otherwise it will be a length-one numeric or
#'   complex vector.
#'
#'   Zero-length vectors have sum 0 by definition. See
#'   \url{http://en.wikipedia.org/wiki/Empty_sum} for more details.
#' @examples
#' sum(1:10)
#' sum(1:5, 6:10)
#' sum(F, F, F, T, T)
#'
#' sum(.Machine$integer.max, 1L)
#' sum(.Machine$integer.max, 1)
#'
#' \dontrun{
#' sum("a")
#' }
sum <- function(..., na.rm = TRUE) {}
```


Indent the second and subsequent lines of a tag so that when scanning the documentation so it's easy to see where one tag ends and the next begins. Tags that always span multiple lines (like `@example`) should start on a new line and don't need to be indented.

## Documenting classes, generics and methods

Documenting classes, generics and methods are relatively straightforward, but there are some variations based on the object system. The following sections give the details for the S3, S4 and RC object systems.

Voir \url{http://en.wikipedia.org/wiki/Empty_sum}  

## Documenting datasets

Datasets are usually stored as `.rdata` files in `data/` and not as regular R objects in the package. This means you need document them slightly differently: instead of documenting the data directly, you document `NULL`, and use `@name` to tell roxygen2 what dataset you're really documenting.

There are two additional tags that are useful for documenting datasets:

* `@format`, which gives an overview of the structure of the dataset.
  If you omit this, roxygen will automatically add something based on the
  first line of `str()` output

* `@source` where you got the data form, often a `\url{}`.

To show how everything fits together, the example below is an excerpt from the roxygen block used to document the diamonds dataset in ggplot2.


```r
#' Prices of 50,000 round cut diamonds.
#'
#' A dataset containing the prices and other attributes of almost 54,000
#' diamonds. The variables are as follows:
#'
#' \itemize{
#'   \item price. price in US dollars (\$326--\$18,823)
#'   \item carat. weight of the diamond (0.2--5.01)
#'   ...
#' }
#'
#' @format A data frame with 53940 rows and 10 variables
#' @source \url{http://www.diamondse.info/}
#' @name diamonds
NULL
```


## Documenting packages

As well as documenting every exported object in the package, you should also document the package itself. Relatively few packages provide package documentation, but it's an extremely useful tool for users, because instead of just listing functions like `help(package = pkgname)` it organises them and shows the user where to get started.

Package documentation should describe the overall purpose of the package and point to the most important functions. It should not contain a verbatim list of functions or copy of `DESCRIPTION`. This file is for human reading, so pick the most important elements of your package.

Package documentation should be placed in `pkgname.R`. Here's an example:


```r
#' Generate R documentation from inline comments.
#'
#' Roxygen2 allows you to write documentation in comment blocks co-located
#' with code.
#'
#' The only function you're likely to need from \pkg{roxygen2} is
#' \code{\link{roxygenize}}. Otherwise refer to the vignettes to see
#' how to format the documentation.
#'
#' @docType package
#' @name roxygen2
NULL
```


Some notes:

* Like for datasets, there isn't a object that we can document directly so
  document `NULL` and use `@name` to say what we're actually documenting

* `@docType package` indicates that the documentation is for the package.
  This will automatically add the corect aliases so that both `?pkgname`
  and `package?pkgname` will find the package help. If there's already
  a function called `pkgname()`, use `@name roxygen2-package`.

* Use `@references` point to published material about the package that
  users might find helpful.

Package documentation is a good place to list all `options()` that a package understands and to document their behaviour. Put in a section called "Package options", as described below.

## Do repeat yourself

There is a tension between the DRY (do not repeat yourself) principle of programming and the need for documentation to be self-contained. It's frustrating to have to navigate through multiple help files in order to pull together all the pieces you need. Roxygen2 provides three ways to avoid repeating yourself in code documentation, while assembling information from multiple places in one documentation file:

* create reusable with templates with `@template` and `@templateVar`
* reuse parameter documentation with `@inheritParams`
* document multiple functions in the same place with `@describeIn` or `@rdname`

### Roxygen templates

Roxygen templates are R files containing only roxygen comments that live in the `man-roxygen` directory. Use `@template file-name` (without extension) to insert the contents of a template into the current documentation.

You can make templates more flexible by using template variables defined with `@templateVar name value`. Template files are run with brew, so you can retrieve values (or execute any other arbitrary R code) with `<%= name %>`.

Note that templates are parsed a little differently to regular blocks, so you'll need to explicitly set the title, description and details with `@title`, `@description` and `@details`.

### Inheriting parameters from other functions

You can inherit parameter descriptions from other functions using `@inheritParams source_function`. This tag will bring in all documentation for parameters that are undocumented in the current function, but documented in the source function. The source can be a function in the current package, `@inheritParams function`, or another package using `@inheritParams package::function`.

Note, however, that inheritance does not chain. In other words, the `source_function` must always be the function that defines the parameter using `@param`.

### Documenting multiple functions in the same file

You can document multiple functions in the same file by using either `@rdname` or `@describeIn` tag. It's a technique best used with caution: documenting too many functions into one place leads to confusing documentation. It's best used when all functions have the same (or very similar) arguments.

`@describeIn` is designed for the most common cases:

* documenting methods in a generic
* documenting methods in a class
* documenting functions with the same (or similar arguments)

It generates a new section, named either "Methods (by class)", "Methods (by generic)" or "Functions". The section contains a bulleted list describing each function, labelled so that you know what function or method it's talking about. Here's an example, documenting an imaginary new generic:


```r
#' Foo bar generic
#'
#' @param x Object to foo.
foobar <- function(x) UseMethod("x")

#' @describeIn foobar Difference between the mean and the median
foobar.numeric <- function(x) abs(mean(x) - median(x))

#' @describeIn foobar First and last values pasted together in a string.
foobar.character <- function(x) paste0(x[1], "-", x[length(x)])
```


An alternative to `@describeIn` is `@rdname`.  It overrides the default file name generated by roxygen and merges documentation for multiple objects into one file. This gives you complete freedom to combine documentation however you see fit. There are two ways to use `@rdname`. You can add documentation to an existing function:


```r
#' Basic arithmetic
#'
#' @param x,y numeric vectors.
add <- function(x, y) x + y

#' @rdname add
times <- function(x, y) x * y
```


Or, you can create a dummy documentation file by documenting `NULL` and setting an informative `@name`.


```r
#' Basic arithmetic
#'
#' @param x,y numeric vectors.
#' @name arith
NULL

#' @rdname arith
add <- function(x, y) x + y

#' @rdname arith
times <- function(x, y) x * y
```


## Sections

You can add arbitrary sections to the documentation for any object with the `@section` tag. This is a useful way of breaking a long details section into multiple chunks with useful headings. Section titles should be in sentence case and must be followed a colon. Titles may only take one line.


```r
#' @section Warning:
#' Do not operate heavy machinery within 8 hours of using this function.
```


To add a subsection, you must use the `Rd` `\subsection{}` command, as follows:


```r
#' @section Warning:
#' You must not call this function unless ...
#'
#' \subsection{Exceptions}{
#'    Apart from the following special cases...
#' }
```


## Back references

The original source location is added as a comment
to the second line of each generated `.Rd` file in the following form:

```
% Please edit documentation in ...
```

`roxygen2` tries to capture all locations from which the documentation is assembled.
For code that *generates* R code with Roxygen comments (e.g., the `Rcpp` package),
the `@backref` tag is provided.
This allows specifying the "true" source of the documentation,
and will substitute the default list of source files.
Use one tag per source file:


```r
#' @backref src/file.cpp
#' @backref src/file.h
```

