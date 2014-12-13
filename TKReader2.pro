TEMPLATE = app

QT += qml quick widgetss

SOURCES += main.cpp \
    twokinds.cpp \
    page_database.cpp \
    pugixml/pugixml.cpp \
    qml_bridge.cpp

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++1y

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    twokinds.h \
    common.h \
    page_database.h \
    pugixml/pugiconfig.hpp \
    pugixml/pugixml.hpp \
    uri.h \
    qml_bridge.h

unix|win32: LIBS += -ltidy -lcurl -lsqlite3

OTHER_FILES +=
