#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <thread>
#include <iostream>
#include <fstream>

#include "common.h"
#include "twokinds.h"
#include "qml_bridge.h"

TKReader::TwoKinds tk;

void MapPages(){
    for(u32 i = 1; i <= tk.GetArchiveLength(); i++)
        tk.GetPage(i);

    std::cout << "Done mapping pages" << std::endl;
}

void SaveFile(std::string path, std::string text){
    std::ofstream ofs;
    ofs.open(path, std::ios::out);

    if(ofs.is_open()){
        ofs << text;
        ofs.close();
    }
}

// That's the moment you notice your joke made it into the code
// Looking at you, Simon XD
void LeaveBehindThemAll(){
    // Leave Trace
    SaveFile(DATA_FOLDER + "Leaving Trace", "Não tenho certeza do que eu coloco aqui\nEntão irei contar a história que explica o por que desses arquivos existirem...\n\n"
                                            "Dia 13 de Dezembro de 2014, aproximadamente às 13:30... Estava conversando no Steam com o Serin quando ele sugeriu que este"
                                            "aplicativo fosse feito em forma de um aplicativo portátil (Que pode ser executado, por exemplo, diretamente de um pen drive)"
                                            "quando ele fez um trocadilho em relação ao Trace (TwoKinds... trace, em inglês, significando rastro), então eu comecei a falar"
                                            "que mesmo assim, o programa ainda deixaria um Keith no computador da pessoa que o executasse... E ele disse: \"Não esquece da Natani\""
                                            "... Aí deu nisso =P\n\nBTW, só tava usando o PtDuBiérri.Culto por que o Google Tradutor não sabe traduzir direito XD");

    // Create lake
    std::string lake = (DATA_FOLDER + "Lake/");
    MKDIR(lake.c_str());

    SaveFile(lake + "The Pirate Bay", "Hey, it's a ship");
    SaveFile(lake + "Leaving Keith" , "Describe my dick: Feral for Natani");
    SaveFile(lake + "Leaving Natani", "Love him, love him not, love him, love him not...");
}

int main(int argc, char *argv[]){
    LeaveBehindThemAll();

    // Load QML application and create bridge
    QApplication app(argc, argv);
    QQmlApplicationEngine *engine = new QQmlApplicationEngine;
    TKReader::QmlBridge bridge(&tk);

    app.setWindowIcon(QIcon("qrc:/icon.png"));
    engine->rootContext()->setContextProperty("twokinds", &bridge);
    engine->load(QUrl(QStringLiteral("qrc:/Reader.qml")));

    printf("QML Offline Storage Path: %s\n", engine->offlineStoragePath().toStdString().c_str());

    // Start threaded mapping of pages
    std::thread(MapPages).detach();

    // And run it
    return app.exec();
}
