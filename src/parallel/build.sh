#!/bin/bash - 
#===============================================================================
#
#          FILE: build.sh
# 
#         USAGE: ./build.sh 
# 
#   DESCRIPTION:  == GNU General Public License
#   COPYRIGHT:   ## This file is part of Infosol Digital Soil Mapping (IDSM) Software Copyright(c) 2007, INRA
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Manuel Martin, manuel.martin@inra.fr
#  ORGANIZATION: INRA
#       CREATED: 06/07/2018 10:21
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
#needsi parallel, doParallel, boot, MPV to be installed

Rscript -e 'require(knitr); knit("parallel.Rmd"); purl("parallel.Rmd")'
pandoc -t beamer parallel.md parallel.pdf
evince parallel.pdf &
