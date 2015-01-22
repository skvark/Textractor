Text Extractor
==============

Work in progress.

Currently works only in landscape orientation and there's some debug code to see the preprocessing result for the image.

Some notes:
- ensure that there's good lighting conditions when taking pictures
- check that there's no shadows or complex textures in the background
- works best with black text and light colored backgrounds

Tesseract OCR is just plain engine so Leptonica is used for preprocessing the image.

Currently following steps will be done before the image is passed to the engine for recognition:

1. Image is first opened using QImage, dpi is set to 300 and the image is saved in TIFF format.
2. Load the tiff image with Leptonica and convert the 32 bpp image to gray 8 bpp image
3. Unsharp mask
4. Adaptive treshold (Otsu's algorithm)

After those steps the image is passed to the Tesseract.
