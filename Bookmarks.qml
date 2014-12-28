import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.LocalStorage 2.0

import "BookmarkDatabase.js" as BookmarkDatabase

Item {
    id: root

    // Initialize database and display all bookmarked pages
    Component.onCompleted:{
        BookmarkDatabase.initialize()
        refresh()
    }

    // Refreshes the items inside
    function refresh(){
        var bookmarks = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)
        bookmarks.transaction(
            function(tx){
                // Select all bookmarks ordered by the index
                var selection = tx.executeSql("SELECT * FROM BOOKMARKS ORDER BY _index;");

                if(selection.rows.length === 0){
                    // Hide the list and display text
                    bookmarks_list.opacity = 0;

                    no_bookmarks.text = "You have no bookmarks"
                    no_bookmarks.opacity = 1;
                }else{
                    // Clear and add entries to the list
                    bookmarks_model.clear()
                    for(var i = 0; i < selection.rows.length; i++){
                        bookmarks_model.append({
                            'index': selection.rows.item(i)._index,
                            'description': selection.rows.item(i).description
                        })
                    }


                    // Hide the text and show the list
                    no_bookmarks.opacity = 0
                    no_bookmarks.text = ""
                    bookmarks_list.opacity = 1
                }
            }
        );
    }

    // Displays the bookmarked pages
    ListView{
        id: bookmarks_list
        anchors.fill: parent
        opacity: 0

        Behavior on opacity { PropertyAnimation {} }

        // Empty model, entries are going to be added at refresh()
        model: ListModel {id: bookmarks_model}

        // List delegate
        delegate: Item{
            height: label.paintedHeight <= 48? 48 : label.paintedHeight + 24
            anchors.right: parent.right
            anchors.left: parent.left

            // When clicked, enter specified index
            MouseArea{
                anchors.fill: parent
                onClicked:{ enterPage(index); }
            }

            // Displays the page index and the description
            Label{
                id: label
                color: "#E0DEDB"
                anchors{
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right

                    leftMargin: 5
                    rightMargin: 5
                }
                font.pixelSize: 16
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter

                text: index + " - " + description
            }

            // Separator
            Rectangle{
                height: 1
                color: "#505050"

                anchors {
                    right: parent.right
                    left: parent.left
                    bottom: parent.bottom
                }
            }
        }
    }

    // Displays if no bookmarks found
    Label{
        id: no_bookmarks
        color: "#E0DEDB"
        text: ""
        opacity: 0
        anchors.centerIn: parent

        Behavior on opacity { PropertyAnimation {} }
    }
}
