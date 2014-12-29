#ifndef QML_BRIDGE_H
#define QML_BRIDGE_H

#include <QObject>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>
#include <QInputDialog>
#include <QDesktopServices>
#include "common.h"
#include "twokinds.h"

#define NO_DESCRIPTION "No description"

namespace TKReader{

class QmlBridge : public QObject
{
    Q_OBJECT
public:
    explicit QmlBridge(TKReader::TwoKinds*, QWidget *parent = 0);
    virtual ~QmlBridge();

    Q_INVOKABLE int     getArchiveLength();
    Q_INVOKABLE void    getPage(int);
    Q_INVOKABLE QString getTextFromDialog(QString, QString);
    Q_INVOKABLE QString getDataFolder();
    Q_INVOKABLE int     getIntFromDialog(QString, QString, int, int);
    Q_INVOKABLE void    openUrl(QString);
    Q_INVOKABLE QString getRawUrl(int);
private:
    TKReader::TwoKinds* twokinds;

signals:
    void pageGot(QStringList page);

public slots:
    void getPageFinished();
};

} // TKReader

#endif // QML_BRIDGE_H
