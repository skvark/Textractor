Text Extractor
==============

Work in progress.
Currently works only in landscape orientation and there's some debug code to see the preprocessing result for the image.

Some notes:
- ensure that there's good lighting conditions when taking pictures
- check that there are no shadows or complex textures in the background
- works best with black text and light colored backgrounds

Environment and building
------------------------

To be able to build this, follow this Gist to setup the environment correctly: https://gist.github.com/skvark/49a2f1904192b6db311a

The spec file is too WIP and throws some errors, ignore them.

Preprocessing
-------------

Tesseract OCR is just plain engine so Leptonica is used for preprocessing the image.

Currently following steps will be done before the image is passed to the engine for recognition:

1. Image is first opened using QImage, dpi is set to 300 and the image is saved in jpg format.
2. Load the jpg image with Leptonica and convert the 32 bpp image to gray 8 bpp image
3. Unsharp mask
4. Adaptive treshold (Otsu's algorithm)

After those steps the image is passed to the Tesseract.

Postprocessing
--------------

The results are filtered based on the word confindence value. Confidence value is a number between 0-100. 0 means that Tesseract wasn't really sure about the detected word and 100 means that Tesseract is sure that the word is what it is.

Currently there's hardcoded limit of 20 for the confidence. Words with confidence value less than that are removed from the results.

Test image and result
---------------------

Original:

![preview](http://relativity.fi/textextractor/original.jpg)

Preprocessed

![preview](http://relativity.fi/textextractor/preprocessed.jpg)

Extracted text:

````
with smooth transitions and animations; a QML-based user interfaces can be connectedVtc—>—a"C—~:~w
based application b3.Cl{."€l1d that implements more complex application functionality or accesses
si‘:lnii*d~party ‘C-’r~’r libraries.
While the Qt ﬁfaniework includes the Qtg Quick module, which contains essential types for creating
Qli/iL~loa,sed user interfaces, the Sailﬁsh Silica module provides additional types speciﬁcally S
designed for use by Sailﬁsh applications. When writing Sailﬁsh applications with QML, you will
need to mal«:e use of both the Sailﬁsh Silica and QtQuick modules. a
The Sailfish Silica module makes it possible to write user interfaces that: S
as have a Sailﬁsh look and feel, so that they ﬁt in with the visual style of standard Sailﬁsh
applications a S S
w behave consistently with standard Sailﬁsh applications (for example, lists should gradually [
fade as they are scrolled past their limits) t l f t .p 1
<9 make use of unique Sailﬁsh application features, such as pulley menus and application p g t
covers i  _
The current wlease of Sailﬁsh Silica is based on Qt 5.0 and QtQuick 2. Sailﬁsh applicationsﬁshouldtp
import version 2.0 of the QtQuick module. a ‘ p _  f
````
