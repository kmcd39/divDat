ddir = "data-raw/"
data.scripts = setdiff(list.files(ddir), "re-generate all data.R")

for( s in data.scripts ) {
  cat("running", s)
  to.run <- paste0(ddir, s)
  source(to.run)
}
