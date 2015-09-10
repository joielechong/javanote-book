#!/bin/bash

# THIS SCRIPT BUILDS THE JAVANOTES PDF FILE (the version without links).

# VARIABLES USED IN THIS SCRIPT CAN BE SET IN BUILT-env.sh; see that file
# for more information.

source BUILD-env.sh

# can't do anything if user hasn't set up xalan, so check that first.

if [ ! -f $XALAN_DIR/xalan.jar ] ; then
   echo Cannot find the xalan.jar file in $XALAN_DIR
   echo Cannot proceed without xalan.
   echo Did you set up Xalan-J correctly?  See README.txt.
   exit 1
fi

XALAN_COMMAND="$JAVA_COMMAND -cp $XALAN_DIR/xalan.jar:$XALAN_DIR/serializer.jar:$XALAN_DIR/xercesImpl.jar:$XALAN_DIR/xml-apis.jar org.apache.xalan.xslt.Process"

cd $JAVANOTES_SOURCE_DIR

rm -rf tex
mkdir tex

echo
echo Building PDF...
echo
echo Running Xalan to create LaTeX source file...

if ! $XALAN_COMMAND -xsl convert-tex.xsl -in javanotes7-tex.xml -out tex/javanotes7.tex ; then
   echo
   echo "An error occurred while trying to run xalan on convert-tex.xsl."
   echo "Cleaning up and exiting from BUILD-PDF.sh"
   echo
   rm -rf tex
   exit 1
fi

echo Copying other files...

mkdir tex/images
cp images-tex/* tex/images
cp texmacros.tex tex

cd tex

echo
echo Running latex three times...
echo

$LATEX_COMMAND javanotes7.tex
$LATEX_COMMAND javanotes7.tex
$LATEX_COMMAND javanotes7.tex

if [ ! -e "javanotes7.dvi" ] ; then
   echo
   echo "An error occurred while trying to run latex on javanotes7.tex."
   echo "Exiting from BUILD-PDF.sh; latex files are in $JAVA_SOURCE_DIR/tex"
   echo
   cd ..
   exit 1
fi

echo
echo Running dvipdf... 
echo

$DVIPDF_COMMAND javanotes7.dvi

if [ ! -e "javanotes7.pdf" ] ; then
   echo
   echo "An error occurred while trying to run dvipdf on javanotes7.dvi."
   echo "Exiting from BUILD-PDF.sh; latex files are in $JAVA_SOURCE_DIR/tex"
   echo
   cd ..
   exit 1
fi

if [ ! -e "$BUILD_OUTPUT_DIR" ] ; then
   mkdir $BUILD_OUTPUT_DIR
fi
   
if ! mv javanotes7.pdf $BUILD_OUTPUT_DIR ; then
   echo "PDF file successfully generated, but could not be moved to $BUILD_OUTPUT_DIR."
   echo "PDF can be found in $JAVA_SOURCE_DIR/tex"
   cd ..
   exit 1
fi

echo
echo "BUILD-pdf.sh completed."
echo "javanotes7.pdf created in $BUILD_OUTPUT_DIR"

cd ..

if [ "$KEEP_LATEX" != "no" ] ; then
   rm -rf $BUILD_OUTPUT_DIR/latex-source
   mv tex $BUILD_OUTPUT_DIR/latex-source
   echo latex-source created in $BUILD_OUTPUT_DIR
else
   rm -rf tex
fi

echo
exit 0

