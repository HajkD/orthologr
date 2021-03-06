% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_features.R
\name{extract_features}
\alias{extract_features}
\title{Helper function to extract gene loci and splice variant IDs from GFF files}
\usage{
extract_features(x, format)
}
\arguments{
\item{x}{a data.frame converted from a \code{gff} or \code{gtf} file.}

\item{format}{either \code{format = "gtf"} or \code{format = "gff"}.}
}
\description{
Extract gene loci and splice variant IDs from GFF files.
}
