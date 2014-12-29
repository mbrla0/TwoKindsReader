#include "qml_bridge.h"

namespace TKReader{

QmlBridge::QmlBridge(TKReader::TwoKinds *twokinds, QWidget *parent) :
    QObject(parent){

    // Define TwoKinds
    this->twokinds = twokinds;
}

QmlBridge::~QmlBridge(){
}

int QmlBridge::getArchiveLength(){
    // Return the archive length
    return this->twokinds->GetArchiveLength();
}

void QmlBridge::getPage(int index){
    // Create a future watcher that will fire getPageURLFinished()
    QFutureWatcher<TKReader::Page>* watcher = new QFutureWatcher<TKReader::Page>();
    QObject::connect(watcher, SIGNAL(finished()), this, SLOT(getPageFinished()));

    // Create a future that will retrieve the TKreader::Page
    QFuture<TKReader::Page> future = QtConcurrent::run(this->twokinds, &TKReader::TwoKinds::GetPage, index);
    watcher->setFuture(future);
}

QString QmlBridge::getTextFromDialog(QString title, QString label){
    // Retrieve description
    QString description = QInputDialog::getText(qobject_cast<QWidget*>(this->parent()), title, label);


    // Return "No description" in case it was left blank or canceled
    return description.isEmpty() ? NO_DESCRIPTION : description;
}

QString QmlBridge::getDataFolder(){
    return QString::fromStdString(DATA_FOLDER);
}

int QmlBridge::getIntFromDialog(QString title, QString label, int min, int max){
    // Retrieve index
    bool ok;
    int index = QInputDialog::getInt(qobject_cast<QWidget*>(this->parent()), title, label, min, min, max, 1, &ok);

    // Return -1 in case the dialog was canceled
    return ok ? index : -1;
}

void QmlBridge::getPageFinished(){
    // Get the watcher and emit pageGot()
    QFutureWatcher<TKReader::Page>* watcher = static_cast<QFutureWatcher<TKReader::Page>*>(sender());

    if(watcher){
        QStringList list;

        list.push_back(QString::fromStdString(watcher->result().timestamp));
        list.push_back(QString::fromStdString(watcher->result().use_local ? watcher->result().local_url  : watcher->result().remote_url));
        list.push_back(QString::fromStdString(watcher->result().use_local ? watcher->result().remote_url : ERROR_IMAGE));
        list.push_back(QString(ERROR_IMAGE));

        emit pageGot(list);
    }
}

void QmlBridge::openUrl(QString url){
    // Opens URL using QDesktopServices
    std::cout << "Opening URL: " << url.toStdString() << std::endl;
    QDesktopServices::openUrl(QUrl(url));
}

QString QmlBridge::getRawUrl(int index){
    // Get page and return its raw_url
    return QString::fromStdString(this->twokinds->GetRawUrl(index));
}

} // TKReader
