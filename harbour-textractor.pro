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
QT += multimedia network core-private qml-private quick

INCLUDEPATH += src/
INCLUDEPATH += lib/

LIBS += -ltesseract -llept -lexif -lpoppler-qt5

QMAKE_RPATHDIR += /usr/share/harbour-textractor/lib/

SOURCES += lib/folderlistmodel/qquickfolderlistmodel.cpp \
    lib/folderlistmodel/fileinfothread.cpp \
    src/pdfhandler.cpp \
    src/PDFThumbnailProvider.cpp
HEADERS += lib/folderlistmodel/qquickfolderlistmodel.h \
    lib/folderlistmodel/fileproperty_p.h \
    lib/folderlistmodel/fileinfothread_p.h \
    src/pdfhandler.h \
    src/PDFThumbnailProvider.h

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

SOURCES += \
    src/tesseractapi.cpp \
    src/imageprocessor.cpp \
    src/harbour-textractor.cpp \
    src/settings.cpp \
    src/cameramodecontrol.cpp \
    src/downloadmanager.cpp

OTHER_FILES += qml/harbour-textractor.qml \
    qml/cover/CoverPage.qml \
    translations/*.ts \
    rpm/harbour-textractor.spec \
    rpm/harbour-textractor.changes.in \
    harbour-textractor.desktop \
    README.md \
    qml/pages/EditPage.qml \
    qml/pages/HintsPage.qml \
    qml/pages/Settings.qml \
    qml/pages/LanguageDialog.qml \
    qml/pages/DownloadDialog.qml \
    qml/pages/CameraPage.qml \
    qml/pages/ResultsPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/DownloadPage.qml \
    qml/pages/About.qml \
    qml/pages/CroppingPage.qml \
    qml/pages/CornerPoint.qml \
    qml/pages/FilePickerDialog.qml \
    qml/pages/PageSelectPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n

HEADERS += \
    src/tesseractapi.h \
    src/imageprocessor.h \
    src/settings.h \
    src/cameramodecontrol.h \
    src/downloadmanager.h

