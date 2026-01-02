#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QFont>
#include <QIcon>

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN) && QT_VERSION_CHECK(5, 6, 0) <= QT_VERSION && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    // 默认字体
    QFont font;
    // 多个字体族
    font.setFamilies({"Maple Mono NF CN", "DIN1451", "Microsoft YaHei UI", "Microsoft YaHei", "SimSun", "NSimSun", "Arial"});
    app.setFont(font);

    app.setWindowIcon(QIcon(":/qt/qml/newyearcountdown/img/ice.png"));

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/newyearcountdown/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
