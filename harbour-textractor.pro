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
TARGET = harbour-textractor

CONFIG += sailfishapp
CONFIG += c++11
QT += multimedia

INCLUDEPATH += src/

LIBS += -ltesseract -llept

QMAKE_RPATHDIR += /usr/share/harbour-textractor/lib/

SOURCES += \
    src/tesseractapi.cpp \
    src/imageprocessor.cpp \
    src/harbour-textractor.cpp \
    src/settings.cpp

OTHER_FILES += qml/harbour-textractor.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    translations/*.ts \
    rpm/harbour-textractor.spec \
    rpm/harbour-textractor.yaml \
    rpm/harbour-textractor.changes.in \
    harbour-textractor.desktop \
    README.md \
    qml/pages/EditPage.qml \
    qml/pages/HintsPage.qml \
    qml/pages/Settings.qml \
    qml/pages/LanguageDialog.qml

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n

HEADERS += \
    src/tesseractapi.h \
    src/imageprocessor.h \
    src/settings.h

