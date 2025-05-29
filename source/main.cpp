
#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QObject>
#include <QTreeView>
#include <QSettings>
#include <QThreadPool>

#include "backend.h"

#define VERSION_NUMBER "1.10"
// TODO: have exit button close everything

// For Window's deployment
//C:\Qt\5.12.6>C:\Qt\5.12.6\msvc2017_64\bin\windeployqt.exe --qmldir C:\Users\DBAharoni\Documents\Projects\Miniscope-DAQ-QT-Software\Miniscope-DAQ-QT-Software\ C:\Users\DBAharoni\Documents\Projects\Miniscope-DAQ-QT-Software\build-Miniscope-DAQ-QT-Software-Desktop_Qt_5_12_6_MSVC2017_64bit-Release\release\Miniscope-DAQ-QT-Software.exe
int main(int argc, char *argv[])
{
    printf("\nThis is a JhouLab custom-built version of Miniscope-DAQ-QT, that auto-detects the Miniscope port number.\n");
    printf("Specifying deviceID = -1 enables auto-detection.\n\n");
    printf("You may see a few pages of OpenCV warnings after this message. These come from the original code (not mine) and seem to be ignorable.\n\n\n\n");

    QSettings settings("JhouLab", "MiniscopeDAQ");

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
    QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
    QGuiApplication::setAttribute(Qt::AA_UseDesktopOpenGL);

    QApplication app(argc, argv);

    qRegisterMetaType < QVector<quint8> >("QVector<quint8>");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

//    qDebug() << "Max Thread:" << QThreadPool().maxThreadCount();

    backEnd backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    engine.load(url);

    backend.root = qobject_cast<QObject *>(engine.rootObjects().value(0));
    backend.qsettings = &settings;

    backend.setVersionNumber(VERSION_NUMBER);

    QString config = settings.value("DefaultConfig").toString();

    if (config != "") {
        // Try to load previous config file.
        if (!backend.loadDefaultConfig(config))
            // Previously stored settings file no longer exists. Remove from settings.
            settings.remove("DefaultConfig");
    }
//    qDebug() << "TTTEEEE" << engine.rootObjects().first()->findChild<QObject*>("treeView");
//    QObject::connect(engine.rootObjects().first()->findChild<QObject*>("treeView"), &QTreeView::clicked, &backend, &backEnd::treeViewclicked);
    QObject::connect(&backend, &backEnd::closeAll, &engine, &QQmlApplicationEngine::quit);
    return app.exec();
}
