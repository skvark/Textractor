Textractor
==========

Textractor is an OCR application for Sailfish OS. Main features:

OCR can be run on:
- an image taken with the app
- an image selected from the device
- a PDF file (one or multiple pages)

Cropping is supported in any reasonable quadrilateral arrangement and perspective correction is applied for the selection. User has access to advanced image preprocessing settings.

Found text can be edited or copied to clipboard. As SFOS is a true multitasking OS, the whole OCR process can be run on background while user can use the device for other purposes at the same time.

Documentation and Help
----------------------

[Textractor Documentation](http://skvark.github.io/Textractor/)

Environment and building
------------------------

To be able to build this, follow this Gist to setup the environment correctly: https://gist.github.com/skvark/49a2f1904192b6db311a

In short:

Add my repositories containing Tesseract OCR and Leptonica to the build machine targets.

Preprocessing
-------------

Tesseract OCR is just plain engine so Leptonica is used for preprocessing the image.

Currently following steps will be done before the image is passed to the engine for recognition:

1. Image is first opened using QImage, dpi is set to 300, image is rotated according to device angle and the image is saved in jpg format.
2. Load the jpg image with Leptonica and convert the 32 bpp image to gray 8 bpp image
3. Unsharp mask
4. Local background normalization with Otsu's algorithm
5. Skew angle detection and rotation (Leptonica decides if the image needs to be rotated)

After those steps the image is passed to the Tesseract.

Test image and result
---------------------

Original:

![preview0](http://relativity.fi/textextractor/original.jpg)

Preprocessed

![preview01](http://relativity.fi/textextractor/preprocessed.jpg)

Extracted text:

````
This is a lot of 12 point text to test the
ocr code and see if it works on all types
of file format.

The quick brown dog jumped over the
lazy fox. The quick brown dog jumped
over the lazy fox. The quick brown dog
jumped over the lazy fox. The quick
brown dog jumped over the lazy fox.






 D R I N K  COFFEE
L Do Stupid Faster
 With More Energy
````
