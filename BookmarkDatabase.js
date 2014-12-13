function initialize(){
    // Loads all bookmarks with LocalStorage
    var db = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)

    db.transaction(
        function(tx){
            // Create the bookmark table if none exists
            tx.executeSql("CREATE TABLE IF NOT EXISTS BOOKMARKS(_index PRIMARY KEY NOT NULL CHECK (_INDEX != 0), description NAME);");
        }
    );
}

function insertBookmark(index, description){
    // Open databse
    var db = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)

    db.transaction(
        function(tx){
            // Insert value
            tx.executeSql("INSERT OR REPLACE INTO BOOKMARKS VALUES(" + index + ", \"" + description + "\");");
        }
    );
}

function deleteBookmark(index){
    // Open databse
    var db = LocalStorage.openDatabaseSync("TKReader.Bookmarks", "1.0", "Bookmarks from TKReader", 100000)

    db.transaction(
        function(tx){
            // Insert value
            tx.executeSql("DELETE FROM BOOKMARKS WHERE _index = " + index + ";");
        }
    );
}
