#ifndef PAGE_DATABASE_H
#define PAGE_DATABASE_H

#include "common.h"

#define DB_FILENAME "Archive.db"
#define URL_FAIL    ".FAIL"

namespace TKReader{

class PageDatabase
{
public:
    PageDatabase();
    virtual ~PageDatabase();

    bool PutPage(Page&);
    Page GetPage(u32);
    std::vector<Page> GetAllPages();

    static int PageVectorCallback(void* v, int argc, char** argv, char** unused);

private:
    sqlite3* database;
};

} // TKReader

#endif // PAGE_DATABASE_H
