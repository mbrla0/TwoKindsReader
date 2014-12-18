#include "page_database.h"

static bool CanFileBeRead(const char* fname){
    FILE *file;
    if ((file = fopen(fname, "r"))){
        fclose(file);
        return true;
    }

    return false;
}

namespace TKReader{

PageDatabase::PageDatabase(){
    // First, create the main folder
    MKDIR(DATA_FOLDER.c_str());

    // Database initialization
    // Open databse
    if(sqlite3_open((DATA_FOLDER + DB_FILENAME).c_str(), &this->database))
        throw std::runtime_error("Could not open database at: " + DATA_FOLDER + DB_FILENAME);
    else{
        // Initialize page table
        char* error = NULL;
        sqlite3_exec(this->database,
                     "BEGIN TRANSACTION; CREATE TABLE IF NOT EXISTS PAGES(_INDEX INTEGER PRIMARY KEY NOT NULL CHECK (_INDEX != 0), URL_REMOTE NAME NOT NULL, URL_LOCAL NAME, TIMESTAMP NAME);",
                     NULL, NULL, &error);

        // In case of error during table creation
        if(error != NULL)
            throw std::runtime_error(std::string("Could not create page table: ") + error);
    }
}

PageDatabase::~PageDatabase(){
    // Close database
    sqlite3_close(this->database);
}

bool PageDatabase::PutPage(Page &page){
    // Add into page table. Example command: ADD OR REPLACE INTO PAGES VALUES(0, "http://twokinds.keenspot.com/images/20141110.jpg", "", "Comic strip for November 10 2014");
    char* error = NULL;
    sqlite3_exec(this->database, ("INSERT OR REPLACE INTO PAGES VALUES(" + std::to_string(page.index) + ",\"" + page.remote_url + "\",\""
                                                                         + page.local_url + "\", \"" + page.timestamp + "\");").c_str(),
                 NULL, NULL, &error);
    sqlite3_exec(this->database, "COMMIT;", NULL, NULL, NULL);

    // Return true if successful
    return error == NULL;
}

Page PageDatabase::GetPage(u32 index){
    // Put page with given index into pages
    std::vector<Page> pages;
    sqlite3_exec(this->database, ("SELECT * FROM PAGES WHERE _INDEX = " + std::to_string(index) + ";").c_str(), PageDatabase::PageVectorCallback, &pages, NULL);

    // Empty page =P
    Page empty;
    empty.remote_url = URL_FAIL;

    // Return empty page in case of miserable fail
    return pages.size() < 1 ? empty : pages[0];
}

std::vector<Page> PageDatabase::GetAllPages(){
    // Put every page in a vector
    std::vector<Page> vector;
    sqlite3_exec(this->database, "SELECT * FROM PAGES;", PageDatabase::PageVectorCallback, &vector, NULL);

    return vector;
}

/// Callback for creating a page vector (See GetAllPages())
int PageDatabase::PageVectorCallback(void *memory, int argc, char **argv, char **){
    // Create a pointer to the vector at memory
    std::vector<Page>* vector = (std::vector<Page>*) memory;

    // Check if there are enough values inside argv
    if(argc < 2)
        return 0;

    // Create a Page with the values from argv (They sould be: int index, string remote_url, string local_url if not null, string timestamp if not null)
    Page page;
    page.index      = atoi(argv[0]);
    page.remote_url = std::string(argv[1]);
    page.local_url  = std::string(argc >= 3 ? argv[2] : "");
    page.use_local  = !page.local_url.empty() || CanFileBeRead(page.local_url.c_str());
    page.timestamp  = std::string(argc >= 4 ? argv[3] : "");

    // Add page to vector
    vector->push_back(page);

    return 0;

}

} // TKReader
