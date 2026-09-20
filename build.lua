#!/usr/bin/env texlua

module = "TeXCHR"

-- there is nothing to docstrip here, the modules are plain .tex files
sourcefiles = {
   "chr.tex", "core.tex", "log.tex", "for.tex", "list.tex", "permute.tex",
   "match.tex", "compose.tex", "rule.tex", "run.tex", "program.tex",
}
installfiles = sourcefiles
unpackfiles  = {}
typesetfiles = {}
docfiles     = {"README.md"}

-- we are plain TeX, so the checks have to be too
checkformat  = "plain"
checkengines = {"pdftex", "tex"}
stdengine    = "pdftex"
specialformats = {
   plain = {
      pdftex = {binary = "pdftex", format = "pdftex"},
      tex    = {binary = "tex",    format = "tex"   },
   },
}
checksuppfiles = {"chr-test.tex"}
