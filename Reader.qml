import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0

import "BookmarkDatabase.js" as BookmarkDatabase

ApplicationWindow {
    id: root
    visible: true
    width: 600
    height: 800
    x: ( Screen.desktopAvailableWidth  / 2 ) - ( width  / 2 )
    y: ( Screen.desktopAvailableHeight / 2 ) - ( height / 2 )

    title: "TwoKinds Reader II"


    // ============== Application content ==============
    // Reader
    Rectangle{
        id: reader_content
        color: "#101010"
        anchors.left: parent.left
        anchors.right: parent.right
        state: "default"
        focus: true

        // States and transitions available for hiding the reader and showing the options
        // DO NOT EDIT THIS! THIS CODE WORKS WITH THE USE OF MAGIC THAT IS BOTH VERY POWERFUL AND VERY UNSTABLE
        // SO THE SLIGHTEST CHANGE WILL PROBABLY UNLEASH ALL OF IT'S CONDENSED ANCIENT ENERGY, CAUSING THE SHATTERING OF REALITY AS WE KNOW TODAY
        // ALSO, FLORA WILL GET MAD IF YOU DO EDIT IT, SO... YEAH... ENOUGH REASONS NOT TO CHANGE IT?
        states:[
            State{
                name: "hidden"

                // Release top, push bottom upwards and lock options_content's bottom
                AnchorChanges {target: reader_content ; anchors.top:    undefined}
                AnchorChanges {target: reader_content ; anchors.bottom: parent.top}
                AnchorChanges {target: options_content; anchors.bottom: parent.bottom}
            },
            State{
                name: "default"

                // Push bottom, anchor up and release options_content's bottom
                AnchorChanges {target: options_content; anchors.bottom: undefined}
                AnchorChanges {target: reader_content ; anchors.top:    parent.top}
                AnchorChanges {target: reader_content ; anchors.bottom: parent.bottom}
            }
        ]
        transitions: [
            Transition{
                from: "*"
                to: "*"

                AnchorAnimation {targets: [reader_content, options_content]; duration: 650}
            }
        ]

        // Enter latest page when completed
        Component.onCompleted: enterPage(0);

        // Click to toggle header and footer
        MouseArea{
            anchors{
                top: header.bottom
                bottom: footer.top
                left: parent.left
                right: parent.right
            }

            onClicked:{
                // Ignore if reader_content is hidden
                if(reader_content.state === "hidden")
                    return

                var state = footer.state

                if(state === "default")
                    footer.state = "hidden"
                else
                    footer.state = "default"

                // Stop the key hide timer if necessarry
                if(key_hide_header.running) key_hide_header.stop()

                if(state === "default")
                    header.state = "hidden"
                else{
                    header.state = "default"
                }
            }
        }

        // You can also use the keyboard to navigate through pages =D
        property bool lock_key_previous: false
        property bool lock_key_next:     false

        Timer{
            id: key_hide_header
            interval: 3000

            onTriggered: header.state = "hidden"
        }
        Timer{
            id: key_previous_unlock
            interval: 250

            // Enter previous page
            onTriggered: reader_content.lock_key_previous = false
        }
        Timer{
            id: key_next_unlock
            interval: 250

            // Enter next page
            onTriggered: reader_content.lock_key_next = false
        }
        Keys.onLeftPressed:{
            // Enter previous page if key not locked, lock and start unlock timer
            if(!lock_key_previous) { enterPage(currentPageIndex === 0 ? twokinds.getArchiveLength() : currentPageIndex - 1); lock_key_previous = true; }
            key_previous_unlock.start()

            // Show header and start hide timer
            if(header.state === "hidden"){
                header.state = "default"
                key_hide_header.restart()
            }
        }
        Keys.onRightPressed:{
            // Enter next page if key not locked, lock and start unlock timer
            if(!lock_key_next) { enterPage(currentPageIndex === twokinds.getArchiveLength() ? 0 : currentPageIndex + 1); lock_key_next = true; }
            key_next_unlock.start()

            // Show header and start hide timer
            if(header.state === "hidden"){
                header.state = "default"
                key_hide_header.restart()
            }
        }

        // Closes options menu
        Keys.onEscapePressed: {
            if(reader_content.state === "hidden"){
                reader_content.state = "default"

            }
        }

        // Main image
        ImageView{
            id: main_image

            anchors.fill: parent
            source: ""

            onStatusChanged: {
                if(status === Image.Error){
                    // Switch source
                    if(source === currentPage[1])
                        source = currentPage[2]
                    else if(source === currentPage[2])
                        source = currentPage[3]
                    else
                        console.log("WTF? Error image(" + currentPage[3] + ") failed to load")
                }
            }
        }

        // Header
        Item{
            id: header
            height: 52
            state: "default"
            anchors.left: parent.left
            anchors.right: parent.right

            Behavior on height { NumberAnimation { } }

            // ============== States and transitions ==============

            states: [
                State{
                    name: "hidden"

                    // Change anchors to hide
                    AnchorChanges {target: header; anchors.top: undefined}
                    AnchorChanges {target: header; anchors.bottom: reader_content.top}
                },
                State{
                    name: "default"

                    // Change to default position
                    AnchorChanges {target: header; anchors.bottom: undefined}
                    AnchorChanges {target: header; anchors.top: reader_content.top}
                }
            ]
            transitions: [
                Transition {
                    from: "*"
                    to: "default"

                    AnchorAnimation {}
                },
                Transition {
                    from: "default"
                    to: "hidden"

                    AnchorAnimation {}
                }
            ]

            // ============== Coloring and effects ==============

            Rectangle{
                id: h_color
                anchors.fill: parent

                color: "#AAC0C0C0"
            }

            FastBlur{
                anchors.fill: h_color
                source: main_image

                radius: 64
            }

            // ============== Elements ==============

            // Page indicator, displays the current page
            Label{
                id: h_page_indicator
                y: 4
                color: "#202020"
                font.family: "Open Sans"
                font.pixelSize: 16
                font.bold: true

                anchors.horizontalCenter: parent.horizontalCenter

            }


            // Timestamp, displays when the page was posted
            Label{
                id: h_timestamp
                y: 26
                color: "#202020"
                font.family: "Open Sans"

                state: "hidden"
                font.pixelSize: 12

                anchors.horizontalCenter: parent.horizontalCenter

                states:[
                    State{
                        name: "hidden"

                        PropertyChanges {target: h_timestamp; opacity: 0}
                        PropertyChanges {target: header     ; height: 32}
                    },
                    State{
                        name: "default"

                        PropertyChanges {target: h_timestamp; opacity: 1}
                        PropertyChanges {target: header     ; height: 48}
                    }
                ]

                Behavior on opacity { NumberAnimation { } }

                onTextChanged:{
                    if(text === "")
                        state = "hidden";
                    else
                        state = "default";
                }
            }

        } // Header

        // Footer
        Item{
            id: footer
            height: 64
            state: "default"
            anchors.left: parent.left
            anchors.right: parent.right

            Behavior on height { NumberAnimation { } }

            // ============== States and transitions ==============

            states: [
                State{
                    name: "hidden"

                    // Change anchors to hide
                    AnchorChanges {target: footer; anchors.top: reader_content.bottom}
                    AnchorChanges {target: footer; anchors.bottom: undefined}
                },
                State{
                    name: "default"

                    // Change to default position
                    // Change anchors to hide
                    AnchorChanges {target: footer; anchors.top: undefined}
                    AnchorChanges {target: footer; anchors.bottom: reader_content.bottom}
                }
            ]
            transitions: [
                Transition {
                    from: "*"
                    to: "default"

                    AnchorAnimation {}
                },
                Transition {
                    from: "default"
                    to: "hidden"

                    AnchorAnimation {}
                }
            ]

            // ============== Coloring and effects ==============

            Rectangle{
                id: f_color
                anchors.fill: parent

                color: "#AAC0C0C0"
            }

            FastBlur{
                anchors.fill: f_color
                source: main_image

                radius: 64
            }

            // ============== Elements ==============

            Item{
                anchors.fill: parent

                // ============== Navigation contols ==============

                Item{
                    id: f_navigation_controls
                    y: 32
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on y { NumberAnimation {} }

                    // Previous
                    Image{
                        id: btn_previous
                        height: 32

                        // Stay to the left of f_page_indicator
                        anchors{
                            right: f_page_indicator.left
                            rightMargin: 10
                            verticalCenter: f_page_indicator.verticalCenter
                        }

                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/arrow_left.png"

                        // Go to the previous page when clicked
                        MouseArea{
                            anchors.centerIn: parent

                            width:  parent.paintedWidth  + 8
                            height: parent.paintedHeight + 16

                            onClicked: enterPage(currentPageIndex === 0 ? twokinds.getArchiveLength() : currentPageIndex - 1)
                        }
                    }

                    // Other page indicator
                    Label{
                        id: f_page_indicator
                        anchors.centerIn: parent
                        color: "#202020"
                        font.family: "Open Sans"
                        font.pixelSize: 16

                        text: currentPageIndex
                    }

                    // Next
                    Image{
                        height: 32

                        // Stay to the right of f_page_indicator
                        anchors{
                            left: f_page_indicator.right
                            leftMargin: 10
                            verticalCenter: f_page_indicator.verticalCenter
                        }

                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/arrow_right.png"

                        // Go to the next page when clicked
                        MouseArea{
                            anchors.centerIn: parent

                            width:  parent.paintedWidth  + 5
                            height: parent.paintedHeight + 5

                            onClicked: enterPage(currentPageIndex === twokinds.getArchiveLength() ? 0 : currentPageIndex + 1)
                        }
                    }
                }

                // ============== Other stuff ==============

                // Displays the bookmark description in case of the page being bookmarked
                Label{
                    id: f_bookmark_description
                    y: 10
                    color: "#202020"
                    font.family: "Open Sans"
                    anchors{
                        left: parent.left
                        right: parent.right

                        leftMargin: 5
                        rightMargin: 5
                    }
                    state: "hidden"
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    clip: false

                    states:[
                        State{
                            name: "hidden"

                            PropertyChanges {target: f_bookmark_description; opacity: 0}
                            PropertyChanges {target: footer                ; height:  64}
                            PropertyChanges {target: f_navigation_controls ; y:       32}
                            PropertyChanges {target: f_bookmark_toggle     ; y:       8}
                            PropertyChanges {target: f_expand_options_menu ; y:       8}
                        },
                        State{
                            name: "default"

                            PropertyChanges {target: f_bookmark_description; opacity: 1}
                            PropertyChanges {target: footer                ; height:  68 + f_bookmark_description.paintedHeight}
                            PropertyChanges {target: f_navigation_controls ; y:      (68 + f_bookmark_description.paintedHeight) - 64 + 32}
                            PropertyChanges {target: f_bookmark_toggle     ; y:      (68 + f_bookmark_description.paintedHeight) - 64 + 8}
                            PropertyChanges {target: f_expand_options_menu ; y:      (68 + f_bookmark_description.paintedHeight) - 64 + 8}
                        }
                    ]

                    Behavior on opacity { NumberAnimation { } }

                    onTextChanged:{
                        if(text === "")
                            state = "hidden";
                        else
                            state = "default";
                    }

                    function refresh(){
                        // Check if current page is valid
                        if(root.currentPageIndex === 0){
                            f_bookmark_description.text = ""
                            return
                        }

                        // Open bookmark database
                        var bookmarks = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)
                        bookmarks.transaction(
                            function(tx){
                                // Try to select the bookmark which has the current pages's index
                                var selection = tx.executeSql("SELECT * FROM BOOKMARKS WHERE _index = " + root.currentPageIndex + ";");

                                // Check if any was found
                                f_bookmark_description.text = selection.rows.length > 0 ? selection.rows.item(0).description : ""
                            }
                        );
                    }
                }

                // Options button (Arrow pointing up)
                Item{
                    id: f_expand_options_menu
                    width:  48 + f_expand_options_menu_label.paintedWidth + 5
                    height: 48
                    y: 8

                    anchors{
                        rightMargin: 15
                        right: parent.right
                    }

                    Behavior on y { NumberAnimation {} }

                    // Open menu once clicked
                    MouseArea{
                        anchors.fill: parent
                        onClicked: reader_content.state = "hidden"
                    }

                    Label{
                        id: f_expand_options_menu_label

                        color: "#202020"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: f_expand_options_menu_icon.left
                        anchors.rightMargin: 10

                        text: "Options"
                    }

                    Image{
                        id: f_expand_options_menu_icon

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        height: 24

                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/arrow_up.png"
                    }
                }

                // Bookmark/Remove button
                Item{
                    id: f_bookmark_toggle
                    width:  48 + f_bookmark_toggle_label.paintedWidth + 5
                    height: 48
                    y: 8
                    state: "none"
                    anchors{
                        leftMargin: 15
                        left: parent.left
                    }

                    Behavior on y { NumberAnimation {} }

                    // Changes the icon
                    states:[
                        State{
                            name: "none"

                            PropertyChanges { target: f_bookmark_toggle_label      ; text: ""   }
                            PropertyChanges { target: f_bookmark_toggle_label      ; opacity: 0 }
                            PropertyChanges { target: f_bookmark_toggle_icon_add   ; opacity: 0 }
                            PropertyChanges { target: f_bookmark_toggle_icon_remove; opacity: 0 }
                        },
                        State{
                            name: "add"

                            PropertyChanges { target: f_bookmark_toggle_label      ; text: "Bookmark" }
                            PropertyChanges { target: f_bookmark_toggle_label      ; opacity: 1       }
                            PropertyChanges { target: f_bookmark_toggle_icon_add   ; opacity: 1       }
                            PropertyChanges { target: f_bookmark_toggle_icon_remove; opacity: 0       }
                        },
                        State{
                            name: "remove"

                            PropertyChanges { target: f_bookmark_toggle_label      ; text: "Remove" }
                            PropertyChanges { target: f_bookmark_toggle_label      ; opacity: 1     }
                            PropertyChanges { target: f_bookmark_toggle_icon_remove; opacity: 1     }
                            PropertyChanges { target: f_bookmark_toggle_icon_add   ; opacity: 0     }
                        }
                    ]

                    // Toggle bookmark
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            if(f_bookmark_toggle.state === "add"){
                                // Add bookmark and refresh bokmarks menu (TODO: Add description dialog)
                                BookmarkDatabase.insertBookmark(currentPageIndex, twokinds.getTextFromDialog("Bookmark", "Bookmark description:"))
                                options_content.refresh()
                                f_bookmark_toggle.refresh()
                                f_bookmark_description.refresh()
                            }else if(f_bookmark_toggle.state !== "none"){
                                // Remove bookmark
                                BookmarkDatabase.deleteBookmark(currentPageIndex)
                                options_content.refresh()
                                f_bookmark_toggle.refresh()
                                f_bookmark_description.refresh()
                            }
                        }
                    }

                    // Text
                    Label{
                        id: f_bookmark_toggle_label
                        color: "#202020"
                        font.family: "Open Sans"
                        font.pixelSize: 16

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: f_bookmark_toggle_icon_add.right
                        anchors.leftMargin: 10

                        Behavior on opacity { NumberAnimation {} }
                    }

                    // Icon
                    Image{
                        id: f_bookmark_toggle_icon_add
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        height: 32

                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/bookmark_add.png"

                        Behavior on opacity { NumberAnimation {} }
                    }
                    Image{
                        id: f_bookmark_toggle_icon_remove
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        height: 28

                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/bookmark_remove.png"

                        Behavior on opacity { NumberAnimation {} }
                    }

                    function refresh(){
                        // Check if current page is valid
                        if(root.currentPageIndex === 0){
                            f_bookmark_toggle.state = "none"
                            return
                        }

                        // Open bookmark database
                        var bookmarks = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)
                        bookmarks.transaction(
                            function(tx){
                                // Try to select the bookmark which has the current pages's index
                                var selection = tx.executeSql("SELECT * FROM BOOKMARKS WHERE _index = " + root.currentPageIndex + ";");

                                // Check if any was found
                                f_bookmark_toggle.state = selection.rows.length > 0 ? "remove" : "add"
                            }
                        );
                    }
                }
            }
        } // Footer

        // Header/Footer effects

    }

    // Options menu below reader
    OptionsMenu{
        id: options_content

        // Show reader in case resume was fired
        onResume: reader_content.state = "default"

        // I always like having a different color in my code ^-^
        anchors.left:  parent.left
        anchors.right: parent.right
        anchors.top:   reader_content.bottom


    }

    // ============== Application bridge ==============
    property int currentPageIndex;
    property var currentPage;

    onCurrentPageChanged:{
        // Set timestamp and image source
        h_timestamp.text = currentPage[0];
        main_image.source = currentPage[1];
    }

    // Needed to fix the "Page spamming multithread slowdown of despair and imminent death"
    Timer{
        id: enter_page_timer
        interval: 750

        onTriggered:
            twokinds.getPage(currentPageIndex);
    }

    function enterPage(index){
        if(index <= twokinds.getArchiveLength() && index >= 0){
            currentPageIndex = index;
            f_bookmark_toggle.refresh()
            f_bookmark_description.refresh()

            // Set the image source
            main_image.state  = "loading";
            main_image.source = "";

            // Set labels
            h_timestamp.text = ""
            h_page_indicator.text = index === 0 ? "Latest page" : "Page number " + index;
            f_page_indicator.text = index === 0 ? "Latest" : index;

            // Call page load timer
            enter_page_timer.restart()

            // And resume reader
            reader_content.state = "default"
        }
    }

    Connections{
        target: twokinds

        // Set the image's source to the page URL
        onPageGot: currentPage = page
    }
}
