#include "twokinds.h"

// Define all the <Plural of XPath> that may be used to query the lastet page and the archived pages (See twokinds.h)
#define XPATH_COUNT_LASTET_IMG  2
#define XPATH_COUNT_ARCHIVE_IMG 2

const char* XPATH_LASTET_IMG[XPATH_COUNT_LASTET_IMG]   = {"//div[@class=\'alt-container\']/a[2]/img[@src]", "//div[@class=\'alt-container\']/img[@src]"};
const char* XPATH_ARCHIVE_IMG[XPATH_COUNT_ARCHIVE_IMG] = {"//div[@class=\'comic\']/p[@id=\'cg_img\']/a[@href]/img[@src]", "//div[@class=\'comic\']/p[@id=\'cg_img\']/img[@src]"};



namespace TKReader{

TwoKinds::TwoKinds() : page_database(), cached_archive_length(0){
}

TwoKinds::~TwoKinds(){
}

u32 TwoKinds::GetArchiveLength(){
    // Use cached version if possible
    if(this->cached_archive_length != 0)
        return this->cached_archive_length;

    // In case it wasn't cached yet
    // Download and tidy archive.php
    std::string str_archive_php = ReadAndTidyFromURL(URL_ARCHIVE);

    if(str_archive_php.empty())
        return 0;

    // Load string into xml_document
    pugi::xml_document archive_php;
    pugi::xml_parse_result parse_result = archive_php.load_buffer(str_archive_php.c_str(), str_archive_php.size());

    if(parse_result.status != pugi::status_ok)
        return 0;

    // Get the url pointing to the last web page in the archive
    pugi::xml_node last_page_url = archive_php.first_child().select_nodes(XPATH_ARCHIVE_LAST_URL)[0].node();

    // Parse it's href using an Uri, then find the page number inside it
    Uri last_page = Uri::Parse(last_page_url.attribute("href").as_string());

    std::vector<std::string> queries = TwoKinds::SplitString(last_page.QueryString, "&");
    for(std::string query : queries){
        std::vector<std::string> query_fragments = TwoKinds::SplitString(query, "=");

        if(query_fragments[0] == "p"){
            // Save length and return it (+1 for the extra page)
            u32 archive_length = atoi(query_fragments[1].c_str()) + 1;

            this->cached_archive_length = archive_length;
            return archive_length;
        }
    }

    return 0;
}

Page TwoKinds::GetPage(u32 index){
    // First: try loading page from database
    Page db = this->page_database.GetPage(index);
    if(db.remote_url != URL_FAIL)
        return db;

    // In case first fails, do this:
    // Create page object
    Page page;
    page.index = index;
    page.use_local = false;

    // Retrieve page url
    bool archived = index > 0;
    if(archived && index <= GetArchiveLength()){
        // Load archive page for given index and load it into a xml_document (In case the last entry is selected, change the url page number to 0)
        std::string str_archive_page = TwoKinds::ReadAndTidyFromURL(BASEURL_ARCHIVE + std::to_string(index));

        pugi::xml_document archive_page;
        pugi::xml_parse_result parse_result = archive_page.load_buffer(str_archive_page.c_str(), str_archive_page.size());

        if(parse_result.status != pugi::status_ok){
            page.remote_url = URL_FAIL;
            return page;
        }

        // Query the image's url and title, add them to page
        pugi::xpath_node_set query_results;

        u32 i = 0;
        do{
            query_results = archive_page.first_child().select_nodes(XPATH_ARCHIVE_IMG[i]);
            ++i;
        }while(query_results.size() <= 0 && i < sizeof(XPATH_COUNT_ARCHIVE_IMG));

        if(query_results.size() <= 0)
            // We got an error
            return Page::GetError();

        pugi::xml_node image = query_results[0].node();
        page.remote_url = image.attribute("src").as_string();

        // Query timestamp and add it to page (Two parts that will be blended in the future)
        std::string timestamp_0;
        std::string timestamp_1;

        pugi::xml_node timestamp = archive_page.first_child().select_nodes(XPATH_ARCHIVE_TIMESTAMP)[0].node();
        timestamp_0 = timestamp.text().as_string();

        timestamp.remove_child(timestamp.first_child());
        timestamp_1 = timestamp.text().as_string();

        page.timestamp = timestamp_0 + timestamp_1;
    }else{
        // Load lastet page and load it into a xml_document
        std::string str_lastet_page = TwoKinds::ReadAndTidyFromURL(URL_LASTET);

        pugi::xml_document lastet_page;
        pugi::xml_parse_result parse_result = lastet_page.load_buffer(str_lastet_page.c_str(), str_lastet_page.size());

        if(parse_result.status != pugi::status_ok){
            page.remote_url = URL_FAIL;
            return page;
        }

        // Query the image's url and title, add them to page
        pugi::xpath_node_set query_results;

        u32 i = 0;
        do{
            query_results = lastet_page.first_child().select_nodes(XPATH_LASTET_IMG[i]);
            ++i;
        }while(query_results.size() <= 0 && i < sizeof(XPATH_COUNT_LASTET_IMG));

        if(query_results.size() <= 0)
            // We got an error
            return Page::GetError();


        pugi::xml_node image = query_results[0].node();
        page.remote_url = std::string(URL_LASTET) + image.attribute("src").as_string();

        // Query timestamp and add it to page
        pugi::xml_node timestamp = lastet_page.first_child().select_nodes(XPATH_LASTET_TIMESTAMP)[0].node();
        page.timestamp = timestamp.text().as_string();
    }

    // Save page on database
    this->page_database.PutPage(page);

    // And return it
    return page;
}

size_t TwoKinds::CurlWriteToStringstreamCallback(char *ptr, size_t size, size_t nmemb, void *userdata){
    // Write to stringstream
    std::ostringstream *stream = (std::ostringstream*) userdata;
    size_t count = size * nmemb;
    stream->write(ptr, count);
    return count;
}
std::string TwoKinds::ReadAndTidyFromURL(std::string url){
    // Read from URL into Stringstream
    CURL* handle = curl_easy_init();

    if(handle){
        std::stringstream sstream;

        curl_easy_setopt(handle, CURLOPT_URL, url.c_str());
        curl_easy_setopt(handle, CURLOPT_USERAGENT, "Mozilla");
        curl_easy_setopt(handle, CURLOPT_WRITEFUNCTION, TwoKinds::CurlWriteToStringstreamCallback);
        curl_easy_setopt(handle, CURLOPT_FILE, &sstream);

        CURLcode result = curl_easy_perform(handle);
        if(result == CURLE_OK){
            // Tidy result
            TidyBuffer output = {0, 0, 0, 0, 0};
            TidyBuffer err = {0, 0, 0, 0, 0};
            int rc = -1;
            Bool ok;

            TidyDoc doc = tidyCreate();

            ok = tidyOptSetBool(doc, TidyXhtmlOut, yes);
            if(ok)
                rc = tidySetErrorBuffer(doc, &err);
            if(rc >= 0)
                rc = tidyParseString(doc, sstream.str().c_str());
            if(rc >= 0)
                rc = tidyCleanAndRepair(doc);
            if(rc >= 0)
                rc = tidyRunDiagnostics(doc);
            if(rc > 1)
                rc = (tidyOptSetBool(doc, TidyForceOutput, yes) ? rc : -1 );
            if(rc >= 0)
                rc = tidySaveBuffer(doc, &output);

            if(rc >= 0){
                 std::stringstream ss;
                 ss << output.bp;

                 std::string s = ss.str();

                 // Tidy sucessful
                 return s;
            }else{
                 std::cerr << err.bp << std::endl;
            }

            tidyBufFree(&output);
            tidyBufFree(&err);
            tidyRelease(doc);

            // Failed to Tidy
            return "";
        }

        // Failed to download
        return "";
    }

    // CRY THUNDER!
    return "";

}
std::vector<std::string> TwoKinds::SplitString(std::string str, std::string sep){
    char* cstr=const_cast<char*>(str.c_str());
    char* current;

    std::vector<std::string> arr;
    current = strtok(cstr,sep.c_str());

    while(current != NULL){
        arr.push_back(current);
        current = strtok(NULL,sep.c_str());
    }

    return arr;
}

} // TKReader
