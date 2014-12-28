#ifndef TWOKINDS_H
#define TWOKINDS_H

#include "common.h"
#include "page_database.h"

// Defines for things that might/will change in the future
// So when I get to change them, I won't have to search trough my code to find these strings '>.<
// NOTE: XPATH_LASTET_IMG and XPATH_ARCHIVE_IMG moved to twokinds.cpp

#define XPATH_ARCHIVE_LAST_URL  "//a[@id=\'cg_back\']"
#define XPATH_ARCHIVE_TIMESTAMP "//div[@class=\'comic\']/p[@class=\'date\']"
#define XPATH_LASTET_TIMESTAMP  "//div[@class=\'alt-container\']/p"

#define BASEURL_ARCHIVE "http://twokinds.keenspot.com/archive.php?p="
#define URL_MAIN        "http://twokinds.keenspot.com/"
#define URL_ARCHIVE     "http://twokinds.keenspot.com/archive.php"

namespace TKReader{

class TwoKinds
{
public:
    TwoKinds();
    virtual ~TwoKinds();

    /**
     * @brief Get page object using a number (page index)
     * @return Corresponding page
     */
    Page GetPage(u32);

    /**
     * @return The length (in pages) of the TwoKinds archives
     */
    u32 GetArchiveLength(bool = false);

private:
    PageDatabase page_database;
    u32 cached_archive_length;

    static size_t CurlWriteToStringstreamCallback(char*, size_t, size_t, void*);
    static std::string ReadAndTidyFromURL(std::string);
    static std::vector<std::string> SplitString(std::string, std::string);
};

} // TKReader

#endif // TWOKINDS_H
