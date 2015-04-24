#!/bin/bash
compileFile() { 
    for i in {1..3}; do 
        pdflatex --shell-escape "$1"; 
    done
    rm *.aux *.log *.out; 
}

mkdir -p PDFs

# Generate the warning page
cd Other/warningPage
rm warningPage.pdf
compileFile warningPage.tex
cd ../../

# Generate the definitions
cd Chapters/
rm definitions.*

echo -e "\documentclass[a4paper]{book}

\input{../Other/packages.tex}\n
\input{../Other/CustomEnvironments.tex}

\\\begin{document}
" > definitions.tex

ls -1 | grep -e Chapter| while read x; do
	sed -n -e '/\\begin{definition}/,/\\end{definition}/p' -e '/^\\section/p' -e '/^\\chapter/p' $x >> definitions.tex
done

echo -e "\n\\\end{document}" >> definitions.tex

compileFile definitions.tex

mv definitions.pdf ../PDFs/Definitions.pdf

rm definitions.*

# Generate the main document
cd ../

# Read the current version
currentVer=$(($(cat Other/documentVersion.vers )+1))
echo $currentVer > Other/documentVersion.vers
# Remove any left over files
rm mainRender.*

# create a copy of the main
cp main.tex mainRender.tex
# Substitute the version
# DO NOT REMOVE THIS CHECK: During the build on the RPi the command for Mac OS X is different
# From the one needed by the RPi
if [[ $(whoami) == "pi" ]]; then 
	sed -i s/Unknown/0.1."$currentVer"/g mainRender.tex
else
	sed -i '' s/Unknown/0.1."$currentVer"/g mainRender.tex
fi
	

compileFile mainRender.tex
rm mainRender.tex
mv mainRender.pdf PDFs/Notes.pdf
