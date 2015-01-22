# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-text-extractor

CONFIG += sailfishapp
QT += multimedia

INCLUDEPATH += src/

LIBS += -ltesseract -llept

QMAKE_RPATHDIR += /usr/share/harbour-text-extractor/lib/

SOURCES += src/harbour-text-extractor.cpp \
    src/tesseractapi.cpp \
    src/imageprocessor.cpp

OTHER_FILES += qml/harbour-text-extractor.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    translations/*.ts \
    rpm/harbour-text-extractor.spec \
    rpm/harbour-text-extractor.yaml \
    rpm/harbour-text-extractor.changes.in \
    harbour-text-extractor.desktop

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

HEADERS += \
    src/tesseractapi.h \
    src/imageprocessor.h
