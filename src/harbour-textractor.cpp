#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QDebug>
#include <tesseractapi.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>
#include <QProcess>
#include <QtGlobal>
#include <locale.h>
#include <settings.h>
#include <QtQml>
#include <cameramodecontrol.h>

int main(int argc, char *argv[])
{
    // Tesseract requires this locale
    setlocale(LC_NUMERIC, "C");
    // Set the tessdata directory prefix env variable
    qputenv("TESSDATA_PREFIX", "/home/nemo/.local/share/harbour-textractor/harbour-textractor/tesseract-ocr/tessdata/");

    QCoreApplication::setApplicationName("harbour-textractor");
    QCoreApplication::setOrganizationName("harbour-textractor");

    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    TesseractAPI interface;
    view->rootContext()->setContextProperty("tesseractAPI", &interface);
    qmlRegisterType<SettingsManager>("harbour.textractor.settingsmanager", 1, 0, "SettingsManager");
    qmlRegisterType<CameraModeControl>("harbour.textractor.cameramodecontrol", 1, 0, "CameraModeControl");
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    view->setSource(SailfishApp::pathTo("qml/harbour-textractor.qml"));
    view->showFullScreen();
    app->exec();
}

