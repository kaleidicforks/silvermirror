module mirror.config;

import core.time;

import mirror.html_template;
import mirror.ratelimit;
import mirror.common;

import url;

import vibe.data.json;

class Config
{
    /// the URL to download
    URL baseURL;

    /// where to put data
    string path;

    /// skip files larger than this
    size_t fileSizeCutoff = 32 * 1024 * 1024;

    /// quit after downloading this many files (handy for testing)
    size_t maxFiles = size_t.max;

    /// bytes/second target
    RateLimiter rateLimiter;

    /// the template to use on downloaded HTML documents
    Template htmlTemplate;

    /// the user agent string to report
    string userAgent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) " ~ 
        "Gecko/20100101 Firefox/47.0";

    this(Json json)
    {
        if ("url" in json)
        {
            baseURL = json["url"].get!string().parseURL;
        }
        if ("fileSizeCutoff" in json)
        {
            fileSizeCutoff = 1024 * json["fileSizeCutoff"].get!size_t;
        }
        if ("maxFiles" in json)
        {
            maxFiles = json["maxFiles"].get!size_t;
        }
        if ("rateLimit" in json)
        {
            rateLimiter = new RateLimiter(1024 * json["rateLimit"].get!size_t, 1.seconds);
        }
        else
        {
            rateLimiter = new RateLimiter(size_t.max, 1.seconds);
        }
        if ("userAgent" in json)
        {
            userAgent = json["userAgent"].get!string;
        }
        if ("template" in json)
        {
            import std.file : readText;
            auto templateFile = json["template"].get!string;
            htmlTemplate = Template.parse(templateFile.readText);
        }
        if ("path" in json)
        {
            path = json["path"].get!string;
        }
        else
        {
            path = baseURL.host;
        }
    }

    this(string path)
    {
        import std.file : readText;
        this(path.readText.parseJsonString);
    }
}
