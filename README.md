
<!-- README.md is generated from README.Rmd. Please edit that file -->
<img src="man/figures/logo.png" align="left" style="margin: 20px 10px 0px 0px;" alt="" width="120"/><br>
<h2>
Create Darwin-Core Archives in R
</h2>

`galaxias` is an R package designed to simplify the process of
converting biodiversity data into [Darwin Core](https://dwc.tdwg.org)
archives (DwCA), facilitating data submission to infrastructures such as
the [Atlas of Living Australia (ALA)](https://www.ala.org.au) and the
[Global Biodiversity Information Facility (GBIF)](https://gbif.org).

## Installation

This package is under active development, and is not yet available on
CRAN. You can install the latest development version from GitHub with:

``` r
# devtools::install_github("atlasoflivingaustralia/galaxias")
devtools::load_all()
#> ℹ Loading galaxias
```

Load the package:

``` r
# library(galaxias)
```

## Basic usage

To construct a Darwin Core Archive, you’ll need two things:

- some biodiversity data, ideally in a csv or similar
- a metadata statement saying what the data is, and who owns it (usually
  you, the submitter)

Below we’ll provide a quick example of each element.

### Biodiversity data

At their most simple, Darwin Core Archives contain observations of
biodiversity, known as “occurrences”. They may *also* contain additional
information, such as how your survey events were structured, or what
images, sounds or videos you took; we will cover these in later
vignettes. An occurrence dataset is a table where each row is an
observation, and each column is a feature of that you observed:

``` r
df <- tibble(
  occurrenceID = c("galaxias-example-01", "galaxias-example-02"),
  decimalLatitude = c(-35.310, -35.273),
  decimalLongitude = c(149.125, 149.133),
  # coordinatePrecision ?
  eventDate = c("14-01-2023T0:23::00Z", "15-01-2023T11:25:00Z"),
  scientificName = c("Callocephalon fimbriatum", "Eolophus roseicapilla"),
  taxonRank = "species",
  basisOfRecord = "humanObservation")
```

Note that normally you’d import your data from an external file
(e.g. reading a `.csv` file with `utils::read.csv()` or
`readr::read_csv()`), but we’ve constructed one here for example
purposes.

The columns of your dataset need to conform to the Darwin Core Standard;
typically this will require some renaming and perhaps some data
manipulation, as described in the `Mapping to Darwin Core` vignette.
There are a lot of Darwin Core terms, but you probably won’t need them
all. You can find out more using the `{tawnydragon}` package, most
easily using the function `tawnydragon::view_terms()`.

### Metadata

Darwin Core Archives use `xml` files to store metadata, but this format
is tricky to work with for data entry. Therefore, we suggest that you
store your metadata as a markdown file, and use `read_md()` and
`write_md()` to migrate between markdown and xml:

``` r
get_blank_metadata() |>
  write_md("test.rmd") # also supports `.qmd` suffix
```

If you’d prefer a bit more guidance on what to include, you can use an
existing metadata entry as an example, and modify it to your needs:

``` r
get_example_metadata(id = "df368") |>
  write_md("example.rmd")
```

Storing metadata in markdown files has several advantages over xml:

- **clarity:** markdown is easy to read and edit
- **persistence:** markdown files live in your file structure rather
  than your R environment, so are easy to store, share and update
- **visualisation:** it is straightforward to render the file as a PDF
  or HTML for viewing or sharing

Once you are done editting your markdwown file, use `read_md()` to
import back into R as an `xml` object:

``` r
metadata <- read_md("test.rmd")
```

### Constructing an archive

In `galaxias`, we construct Darwin Core Archives by adding data to a
single object, created using the `dwca()` function:

``` r
archive <- dwca() |>
  add_occurrences(df) |>
  add_metadata(metadata)

archive
#> An object of class `dwca` containing: 
#> • occurrences; metadata
```

We suggest using piped syntax. The sequence in which arguments are added
doesn’t matter this time, but would matter if you were adding multiple
different kinds of data. See the `Structure of DwCAs` vignette for
details.

### Checking and submitting

`galaxias` provides two ways to check a DwCA; locally and online. We
suggest using both, in sequence, to avoid any surprises.

To check a `dwca` object locally, use `check_dwca()`:

``` r
# check_dwca(archive)
```

*Q: Include a report option?*

Once you’ve checked your object locally, you can use `build_dwca()` to
convert it into a ‘real’ DwCA (i.e. a `.zip` file).

``` r
archive |>
  build_dwca("my_dwca.zip")
#> Building my_dwca.zip
#> Cleaning temporary directory
```

The validate function takes a DwCA as an input, and passes it to to the
ALA validation API for checking.

*Q: function name to ‘submit’ data?*
