Text Extractor
==============

Work in progress.

Some notes:
- ensure that there's good lighting conditions when taking pictures
- check that there are no shadows or complex textures in the background
- works best with black text and light colored backgrounds

Environment and building
------------------------

To be able to build this, follow this Gist to setup the environment correctly: https://gist.github.com/skvark/49a2f1904192b6db311a

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

Postprocessing
--------------

The results are filtered based on the word confindence value. Confidence value is a number between 0-100. 0 means that Tesseract wasn't really sure about the detected word and 100 means that Tesseract is sure that the word is what it is.

Currently there's hardcoded limit of 20 for the confidence. Words with confidence value less than that are removed from the results.

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
Screenshots
-----------

![preview1](http://relativity.fi/textextractor/20150124230240.jpg)
![preview2](http://relativity.fi/textextractor/20150124230321.jpg)
![preview3](http://relativity.fi/textextractor/20150124230358.jpg)
![preview4](http://relativity.fi/textextractor/20150124230430.jpg)
![preview5](http://relativity.fi/textextractor/20150124230449.jpg)
