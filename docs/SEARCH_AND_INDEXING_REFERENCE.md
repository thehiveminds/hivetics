# Search & Indexing API Source Report: Google Search Console & Bing Webmaster

> **Scope**: Complete developer data-fetch specification for search engine analytics, crawling diagnostics, sitemaps management, and live URL indexing inspection across **Google Search Console** and **Bing Webmaster Tools**.  
> **Format**: Authentication protocols, exact endpoints, HTTP methods, headers, query parameters, request bodies, response models, and key Swift codebase functions. No UI bindings or framework boilerplate.

---

## Codebase Implementation Map

| Engine | Primary Network Client | Model Definitions | Views & Controllers |
|---|---|---|---|
| **Google Search Console** | [`SearchConsoleDetailAPI.swift`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift) | [`SearchConsoleDetailModels.swift`](file:///e:/verceltics/ios/verceltics/Models/SearchConsoleDetailModels.swift) | [`SearchConsoleDetailView.swift`](file:///e:/verceltics/ios/verceltics/Views/SearchConsoleDetailView.swift) |
| **Bing Webmaster Tools** | [`SiteIntegrationDetailAPI.swift`](file:///e:/verceltics/ios/verceltics/Network/SiteIntegrationDetailAPI.swift#L1124-L1173) | [`SiteIntegrationModels.swift`](file:///e:/verceltics/ios/verceltics/Models/SiteIntegrationModels.swift) | [`SiteIntegrationProviderDetailView.swift`](file:///e:/verceltics/ios/verceltics/Views/SiteIntegrationProviderDetailView.swift) |

---

## 1. Google Search Console & Indexing API

### 1.1 Base URLs & Protocol Architecture
- **Webmasters & Sitemaps Base**: `https://www.googleapis.com/webmasters/v3`
- **URL Inspection Base**: `https://searchconsole.googleapis.com/v1/urlInspection/index:inspect`
- **Token Type**: Google OAuth 2.0 Access Token (`GoogleOAuthCredential`)
- **Headers**:
  ```http
  Authorization: Bearer {accessToken}
  Accept: application/json
  Content-Type: application/json
  ```
- **Timeout**: 30 seconds (`timeoutInterval = 30`)
- **Maximum Buffer Size**: 32 MB (`maximumResponseBytes = 32 * 1024 * 1024`)

### 1.2 Property URL Normalization & RFC 3986 Encoding
Google properties are formatted either as full URL prefixes or domain properties:
1. **URL-Prefix Properties**: `https://example.com/` (normalized, lowercase scheme/host, trailing slash preserved).
2. **Domain Properties**: `sc-domain:example.com` (no protocol, no slash, no path).
3. **Path Segment Encoding ([`percentEncodedPathSegment`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L351-L356))**:
   - Path variables like `{siteUrl}` must be strictly percent-encoded using RFC 3986.
   - Any character outside `[a-zA-Z0-9-._~]` is converted to uppercase hex (`%2F`, `%3A`, etc.).
   - Example: `https://example.com/` becomes `https%3A%2F%2Fexample.com%2F`.

---

### 1.3 Key Methods: Sites & Property Inventory

#### 1.3.1 List Verified Sites
- **Swift Method**: [`SearchConsoleDetailAPI.listSites()`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L110-L113)
- **Endpoint**: `GET https://www.googleapis.com/webmasters/v3/sites`
- **Returns**: Array `siteEntry[]`:
  - `siteUrl`: Unique site identifier (e.g. `https://example.com/` or `sc-domain:example.com`)
  - `permissionLevel`: `siteOwner`, `siteFullUser`, `siteRestrictedUser`, `siteUnverifiedUser`

#### 1.3.2 Get Specific Site
- **Swift Method**: [`SearchConsoleDetailAPI.getSite(_ siteURL: String)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L115-L117)
- **Endpoint**: `GET https://www.googleapis.com/webmasters/v3/sites/{siteUrl}`
- **Returns**: `SearchConsoleSite` with `siteUrl` and `permissionLevel`.

#### 1.3.3 Add / Verify Site Property
- **Swift Method**: [`SearchConsoleDetailAPI.addSite(_ siteURL: String)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L119-L121)
- **Endpoint**: `PUT https://www.googleapis.com/webmasters/v3/sites/{siteUrl}`
- **Returns**: HTTP 204 No Content on success.

#### 1.3.4 Delete Site Property
- **Swift Method**: [`SearchConsoleDetailAPI.deleteSite(_ siteURL: String)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L123-L125)
- **Endpoint**: `DELETE https://www.googleapis.com/webmasters/v3/sites/{siteUrl}`
- **Returns**: HTTP 204 No Content on success.

---

### 1.4 Key Methods: Search Analytics Performance Queries

#### 1.4.1 Query Search Performance
- **Swift Methods**:
  - Single page query: [`SearchConsoleDetailAPI.querySearchAnalytics(siteURL:query:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L53-L58)
  - Auto-paginated chunk fetcher: [`SearchConsoleDetailAPI.queryAllSearchAnalytics(siteURL:query:maximumRows:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L60-L93)
- **Endpoint**: `POST https://www.googleapis.com/webmasters/v3/sites/{siteUrl}/searchAnalytics/query`
- **Request Body Payload**:
  ```json
  {
    "startDate": "2026-08-01",
    "endDate": "2026-08-28",
    "dimensions": ["query", "page", "country", "device", "searchAppearance", "date", "hour"],
    "searchType": "web",
    "aggregationType": "auto",
    "dataState": "all",
    "rowLimit": 25000,
    "startRow": 0,
    "dimensionFilterGroups": [
      {
        "groupType": "and",
        "filters": [
          {
            "dimension": "query",
            "operator": "contains",
            "expression": "nextjs"
          }
        ]
      }
    ]
  }
  ```

#### Field Specifications & Constraints:
- **`startDate` / `endDate`**: Format `YYYY-MM-DD`. Validated against Gregorian calendar using America/Los_Angeles timezone.
- **`dimensions`**: Any combination of:
  - `date`: Daily breakdown.
  - `hour`: Hourly breakdown (requires `dataState: "hourly_all"`).
  - `query`: Search query keyword.
  - `page`: Landing page URL.
  - `country`: 3-letter ISO-3166-1 alpha-3 country code (e.g. `usa`, `gbr`).
  - `device`: `DESKTOP`, `MOBILE`, `TABLET`.
  - `searchAppearance`: Rich result visual feature (e.g. `AMP_ARTICLE`, `RECIPE`, `PRODUCT_RESULTS`).
- **`searchType`**: `web` (default), `image`, `video`, `news`, `discover`, `googleNews`.
- **`aggregationType`**:
  - `auto`: Automatically select optimal grouping.
  - `byPage`: Aggregate performance by unique page URL.
  - `byProperty`: Aggregate performance at the property domain level (incompatible with `page` dimension).
  - `byNewsShowcasePanel`: Dedicated for Discover/Google News panels with `NEWS_SHOWCASE` filter.
- **`dataState`**: `all` (includes fresh unconfirmed data), `final` (only finalized historical data), `hourly_all` (required for hourly breakdowns).
- **`rowLimit`**: Minimum 1, maximum 25,000 per request.
- **`startRow`**: Zero-based offset for pagination.
- **Filter Operators**: `contains`, `equals`, `notContains`, `notEquals`, `includingRegex`, `excludingRegex`.

#### Response Payload:
```json
{
  "rows": [
    {
      "keys": ["react hosting", "https://example.com/hosting", "usa", "DESKTOP"],
      "clicks": 425.0,
      "impressions": 12850.0,
      "ctr": 0.03307,
      "position": 3.42
    }
  ],
  "responseAggregationType": "byPage"
}
```

#### Pagination Engine ([`queryAllSearchAnalytics`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L60-L93)):
The method loops sequentially through result sets:
1. Emits request with `startRow = offset` and `rowLimit = 25_000`.
2. Appends returned `page.rows` to cumulative storage.
3. Continues until `page.rows.count < query.rowLimit` or `rows.count >= maximumRows` (hard cap: 100,000 rows).

---

### 1.5 Key Methods: Sitemaps Management

#### 1.5.1 List Submitted Sitemaps
- **Swift Method**: [`SearchConsoleDetailAPI.listSitemaps(siteURL:sitemapIndex:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L160-L168)
- **Endpoint**: `GET https://www.googleapis.com/webmasters/v3/sites/{siteUrl}/sitemaps{?sitemapIndex=url}`
- **Returns**: Array `sitemap[]`:
  - `path`: Full HTTP/HTTPS URL of sitemap
  - `lastSubmitted`: ISO-8601 timestamp
  - `lastDownloaded`: ISO-8601 timestamp
  - `isPending`: `true` if Google is currently processing the sitemap
  - `isSitemapsIndex`: `true` if this is a parent sitemap index containing child sitemaps
  - `type`: `sitemap`, `rssFeed`, `atomFeed`
  - `warnings`: Count of warnings encountered during parsing
  - `errors`: Count of fatal errors encountered during parsing
  - `contents[]`:
    - `type`: Content category (`web`, `image`, `video`, `news`, `mobile`)
    - `submitted`: Total count of URLs submitted in sitemap
    - `indexed`: Total count of submitted URLs indexed in Google

#### 1.5.2 Submit / Refresh Sitemap
- **Swift Method**: [`SearchConsoleDetailAPI.submitSitemap(siteURL:feedpath:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L174-L178)
- **Endpoint**: `PUT https://www.googleapis.com/webmasters/v3/sites/{siteUrl}/sitemaps/{feedpath}`
- **Returns**: HTTP 204 No Content on success.

#### 1.5.3 Delete Sitemap
- **Swift Method**: [`SearchConsoleDetailAPI.deleteSitemap(siteURL:feedpath:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L180-L184)
- **Endpoint**: `DELETE https://www.googleapis.com/webmasters/v3/sites/{siteUrl}/sitemaps/{feedpath}`
- **Returns**: HTTP 204 No Content on success.

---

### 1.6 Key Method: Live Google URL Inspection & Indexing Diagnostics

- **Swift Method**: [`SearchConsoleDetailAPI.inspectURL(_:siteURL:languageCode:)`](file:///e:/verceltics/ios/verceltics/Network/SearchConsoleDetailAPI.swift#L236-L250)
- **Endpoint**: `POST https://searchconsole.googleapis.com/v1/urlInspection/index:inspect`
- **Request Body**:
  ```json
  {
    "inspectionUrl": "https://example.com/blog/my-post",
    "siteUrl": "https://example.com/",
    "languageCode": "en-US"
  }
  ```
- **Language Code**: Validated BCP-47 language tag (length 2–35, alphanumerics and hyphens).

#### Complete URL Inspection Response Structure ([`SearchConsoleURLInspectionResult`](file:///e:/verceltics/ios/verceltics/Models/SearchConsoleDetailModels.swift#L460-L509)):
```json
{
  "inspectionResult": {
    "inspectionResultLink": "https://search.google.com/search-console/inspect?resource_id=...&id=...",
    "indexStatusResult": {
      "verdict": "PASS",
      "coverageState": "Submitted and indexed",
      "robotsTxtState": "ALLOWED",
      "indexingState": "INDEXING_ALLOWED",
      "lastCrawlTime": "2026-08-25T14:32:10Z",
      "pageFetchState": "SUCCESSFUL",
      "googleCanonical": "https://example.com/blog/my-post",
      "userCanonical": "https://example.com/blog/my-post",
      "crawledAs": "GOOGLEBOT_MOBILE",
      "referringUrls": ["https://example.com/blog", "https://example.com/sitemap.xml"],
      "sitemap": ["https://example.com/sitemap.xml"]
    },
    "ampResult": {
      "verdict": "PASS",
      "ampUrl": "https://example.com/blog/my-post/amp",
      "robotsTxtState": "ALLOWED",
      "indexingState": "INDEXING_ALLOWED",
      "ampIndexStatusVerdict": "PASS",
      "lastCrawlTime": "2026-08-25T14:32:11Z",
      "pageFetchState": "SUCCESSFUL",
      "issues": []
    },
    "mobileUsabilityResult": {
      "verdict": "PASS",
      "issues": []
    },
    "richResultsResult": {
      "verdict": "PASS",
      "detectedItems": [
        {
          "richResultType": "Breadcrumbs",
          "items": [
            {
              "name": "Home > Blog > Post",
              "issues": []
            }
          ]
        },
        {
          "richResultType": "Article",
          "items": [
            {
              "name": "How to optimize deployment pipelines",
              "issues": []
            }
          ]
        }
      ]
    }
  }
}
```

#### Detailed Inspection Diagnostics Fields:
1. **`indexStatusResult.coverageState`**:
   - `Submitted and indexed`: Normal, live in Google search index.
   - `Crawled - currently not indexed`: Google visited the page but decided not to index it.
   - `Discovered - currently not indexed`: Google found the URL but has not crawled it yet to preserve crawl budget.
   - `Page with redirect`: Redirected to another destination.
   - `Excluded by ‘noindex’ tag`: Blocked by robots meta tag or HTTP X-Robots-Tag header.
   - `Alternate page with proper canonical tag`: Secondary duplicate correctly pointing to canonical.
2. **`indexStatusResult.robotsTxtState`**: `ALLOWED` or `DISALLOWED`.
3. **`indexStatusResult.pageFetchState`**: `SUCCESSFUL`, `SOFT_404`, `BLOCKED_ROBOTS_TXT`, `NOT_FOUND`, `ACCESS_DENIED`, `SERVER_ERROR`.
4. **`indexStatusResult.crawledAs`**: `GOOGLEBOT_MOBILE` or `GOOGLEBOT_DESKTOP`.
5. **`richResultsResult`**: Reports detected structured data items and syntax warnings/errors for schema types (Breadcrumbs, Articles, FAQs, Organization, Sitelinks).

---

## 2. Bing Webmaster Tools

### 2.1 Base URLs & Protocol Architecture
- **Base URL**: `https://ssl.bing.com/webmaster/api.svc/json`
- **Token Type**: Bing Webmaster API Key
- **Auth Format**: Query parameter `apikey={apiKey}`
- **Header**: `Accept: application/json`
- **Primary Swift Function**: [`SiteIntegrationDetailAPI.fetchBing(siteURL:apiKey:)`](file:///e:/verceltics/ios/verceltics/Network/SiteIntegrationDetailAPI.swift#L1124-L1173)

---

### 2.2 Requests & Endpoints

#### 2.2.1 Overall Traffic & Ranking Trends
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetRankAndTrafficStats?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `Date`: ISO timestamp (`YYYY-MM-DD`)
  - `Clicks`: Organic search clicks from Bing
  - `Impressions`: Total organic search impressions
  - `AvgImpressionPosition`: Average search ranking on Bing SERP
  - `AvgClickPosition`: Average position for clicks

#### 2.2.2 Crawl Diagnostics & Health Statistics
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetCrawlStats?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `Date`: Timestamp
  - `CrawlPages`: Count of pages successfully downloaded by Bingbot
  - `DnsFailures`: DNS resolution failures
  - `ConnectFailures`: TCP handshake connection timeouts
  - `Http4xx`: Client errors encountered
  - `Http5xx`: Server errors encountered
  - `BlockedRobotsTxt`: URLs blocked by robots.txt
  - `CrawlSize`: Total data transferred in kilobytes (KB)

#### 2.2.3 Top Search Queries
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetQueryStats?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `Query`: User query search phrase
  - `Clicks`: Clicks for query
  - `Impressions`: Impressions for query
  - `AvgImpressionPosition`: Ranking position on Bing
  - `AvgClickPosition`: Click position on Bing

#### 2.2.4 Top Indexed Pages
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetPageStats?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `Url`: Page URL
  - `Clicks`: Organic clicks
  - `Impressions`: Organic impressions
  - `AvgImpressionPosition`: Average position

#### 2.2.5 Crawl Issues & Errors
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetCrawlIssues?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `IssueType`: Diagnostic code (`Http404`, `BlockedByRobotsTxt`, `ConnectFailure`, `MalwareInfected`, `DnsFailure`)
  - `Url`: Specific failing URL
  - `FirstDetected`: Timestamp when Bingbot first encountered the failure

#### 2.2.6 Sitemaps & Feeds Status
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetFeeds?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `FeedUrl`: Sitemap URL
  - `Submitted`: Submission timestamp
  - `Status`: `Submitted`, `Processing`, `Success`, `Error`
  - `UrlsSubmitted`: Total submitted URL count
  - `UrlsIndexed`: Total indexed URL count

#### 2.2.7 Inbound Backlink Counts
- **Endpoint**: `GET https://ssl.bing.com/webmaster/api.svc/json/GetLinkCounts?siteUrl={siteUrl}&apikey={apiKey}`
- **Returns**: Array `d[]`:
  - `Url`: Indexed page URL
  - `InboundLinks`: Total count of external inbound links pointing to this page
