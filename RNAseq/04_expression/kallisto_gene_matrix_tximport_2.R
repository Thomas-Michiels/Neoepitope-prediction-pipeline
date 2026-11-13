#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
gtf     <- args[1]
in_tsv  <- args[2]
out_tsv <- args[3]

suppressPackageStartupMessages(library(tximport))

# --- helpers to extract GTF attributes ---
get_attr <- function(attr, key) {
  m <- regexpr(paste0(key, '\\s+"([^"]+)"'), attr, perl=TRUE)
  if (m[1] == -1) return(NA_character_)
  sub(paste0('.*', key, '\\s+"([^"]+)".*'), '\\1', attr, perl=TRUE)
}

# --- stream GTF, collect transcript -> gene and gene_name ---
tx_ids <- character()
gn_ids <- character()
gname_map <- new.env(parent=emptyenv())  # gene_id -> gene_name (first seen)

con <- file(gtf, open="r")
on.exit(close(con), add=TRUE)

repeat {
  line <- readLines(con, n=100000, warn=FALSE)
  if (length(line) == 0) break
  line <- line[substr(line, 1, 1) != "#"]
  if (length(line) == 0) next

  f <- strsplit(line, "\t", fixed=TRUE)
  keep <- vapply(f, function(x) length(x) >= 9 && x[[3]] == "transcript", logical(1))
  if (!any(keep)) next
  f <- f[keep]

  attr <- vapply(f, `[[`, "", 9)

  gene_id <- vapply(attr, get_attr, "", key="gene_id")
  tx_id   <- vapply(attr, get_attr, "", key="transcript_id")
  tx_ver  <- vapply(attr, get_attr, "", key="transcript_version")
  gname   <- vapply(attr, get_attr, "", key="gene_name")

  ok <- !is.na(gene_id) & !is.na(tx_id)
  if (!any(ok)) next

  gene_id <- gene_id[ok]
  tx_id   <- tx_id[ok]
  tx_ver  <- tx_ver[ok]
  gname   <- gname[ok]

  # kallisto target_id example: ENST....1  (versioned)
  txname <- ifelse(!is.na(tx_ver) & nzchar(tx_ver), paste0(tx_id, ".", tx_ver), tx_id)

  tx_ids <- c(tx_ids, txname)
  gn_ids <- c(gn_ids, gene_id)

  # store gene_name if present and not stored yet
  for (i in seq_along(gene_id)) {
    if (!is.na(gname[i]) && nzchar(gname[i]) && !exists(gene_id[i], envir=gname_map, inherits=FALSE)) {
      assign(gene_id[i], gname[i], envir=gname_map)
    }
  }
}

tx2gene <- unique(data.frame(TXNAME=tx_ids, GENEID=gn_ids, stringsAsFactors=FALSE))

# --- tximport (single sample) ---
txi <- tximport(c(sample=in_tsv), type="kallisto", tx2gene=tx2gene, ignoreTxVersion=FALSE)

gene_id <- rownames(txi$abundance)
gene_name <- vapply(gene_id, function(g) if (exists(g, envir=gname_map, inherits=FALSE)) get(g, envir=gname_map) else NA_character_, "")

out <- data.frame(
  gene_id    = gene_id,
  gene_name  = gene_name,
  TPM        = as.numeric(txi$abundance[,1]),
  est_counts = as.numeric(txi$counts[,1]),
  stringsAsFactors=FALSE
)

write.table(out, out_tsv, sep="\t", quote=FALSE, row.names=FALSE)
