# Universal API Source Report: 27 Infrastructure Integrations

> **Scope**: Complete developer data-fetch specification for all 27 cloud platform integrations across **Hosting (10)**, **Domains / Registrars (8)**, and **Site Services (9)**.  
> **Format**: Token format, authentication headers, exact request URLs, query parameters, payload structures, pagination algorithms, and exact data fields returned. No UI code, framework bindings, or platform-specific wrappers.

---

## Table of Contents

1. [Hosting Platforms (10 Integrations)](#1-hosting-platforms-10-integrations)
   - [1.1 Vercel](#11-vercel)
   - [1.2 Cloudflare](#12-cloudflare)
   - [1.3 Netlify](#13-netlify)
   - [1.4 Railway](#14-railway)
   - [1.5 Render](#15-render)
   - [1.6 DigitalOcean App Platform](#16-digitalocean-app-platform)
   - [1.7 Heroku](#17-heroku)
   - [1.8 Fly.io](#18-flyio)
   - [1.9 Firebase Hosting](#19-firebase-hosting)
   - [1.10 AWS Amplify](#110-aws-amplify)
2. [Domain Registrars (8 Integrations)](#2-domain-registrars-8-integrations)
   - [2.1 Name.com](#21-namecom)
   - [2.2 Namecheap](#22-namecheap)
   - [2.3 Porkbun](#23-porkbun)
   - [2.4 Spaceship](#24-spaceship)
   - [2.5 Dynadot](#25-dynadot)
   - [2.6 NameSilo](#26-namesilo)
   - [2.7 Gandi](#27-gandi)
   - [2.8 GoDaddy](#28-godaddy)
3. [Site Services (9 Integrations)](#3-site-services-9-integrations)
   - [3.1 Google Search Console](#31-google-search-console)
   - [3.2 Google Analytics 4 (GA4)](#32-google-analytics-4-ga4)
   - [3.3 PageSpeed Insights & Chrome UX Report (CrUX)](#33-pagespeed-insights--chrome-ux-report-crux)
   - [3.4 Bing Webmaster Tools](#34-bing-webmaster-tools)
   - [3.5 Microsoft Clarity](#35-microsoft-clarity)
   - [3.6 Plausible Analytics](#36-plausible-analytics)
   - [3.7 Umami Analytics (Cloud & Self-Hosted)](#37-umami-analytics-cloud--self-hosted)
   - [3.8 UptimeRobot](#38-uptimerobot)
   - [3.9 Better Stack](#39-better-stack)

---

# 1. Hosting Platforms (10 Integrations)

---

### 1.1 Vercel
- **Base URL**: `https://api.vercel.com`
- **Token Type**: Vercel Personal Access Token
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
1. **User Profile & Verification**:
   - `GET /v2/user`
   - **Returns**: `user.id`, `user.name`, `user.username`, `user.email`, `user.avatar`
2. **Teams Discovery**:
   - `GET /v2/teams`
   - **Returns**: Array `teams[]` with `id`, `slug`, `name`, `membership.confirmed`
3. **Projects List (Personal & Per-Team)**:
   - `GET /v9/projects?limit=100{&teamId=team_xxx}`
   - **Returns**: Array `projects[]`:
     - `id`: Project ID (e.g. `prj_xxx`)
     - `name`: Project name
     - `framework`: Framework preset (e.g. `nextjs`, `vite`, `remix`)
     - `updatedAt`: Millisecond timestamp
     - `targets.production.url`: Production deployment domain
     - `latestDeployments[]`: Last active deployments (`id`, `url`, `readyState`)
4. **Project Custom Domains**:
   - `GET /v9/projects/{projectIdOrName}/domains{&teamId=team_xxx}`
   - **Returns**: Array `domains[]`:
     - `name`: Domain string (e.g. `example.com`)
     - `apexName`: Root domain
     - `verified`: Boolean
     - `verification[]`: Required DNS TXT/CNAME records if unverified
5. **Deployments History**:
   - `GET /v6/deployments?projectId={id}&limit=20{&teamId=team_xxx}`
   - **Returns**: Array `deployments[]`:
     - `uid`: Deployment ID (`dpl_xxx`)
     - `name`: Project name
     - `url`: Auto-generated deployment URL (`xxx.vercel.app`)
     - `state`: Status (`READY`, `BUILDING`, `ERROR`, `CANCELED`, `QUEUED`)
     - `created`: Millisecond timestamp
     - `creator.username`: Committer / deployer
     - `meta.githubCommitRef`: Branch name (e.g. `main`)
     - `meta.githubCommitSha`: Git SHA
6. **Deployment Logs**:
   - `GET /v2/deployments/{id}/events`
   - **Returns**: Log stream array with `event`, `text`, `created`

---

### 1.2 Cloudflare
- **Base URL**: `https://api.cloudflare.com/client/v4`
- **Token Types**:
  - **Scoped API Token (Recommended)**: `Authorization: Bearer {token}`
  - **Global API Key**: `X-Auth-Key: {globalKey}`, `X-Auth-Email: {accountEmail}`

#### Requests & Endpoints
1. **Accounts List**:
   - `GET /accounts`
   - **Returns**: Array `result[]`: `id`, `name`, `type`
2. **DNS Zones Inventory**:
   - `GET /zones?per_page=50{&account.id=xxx}`
   - **Returns**: Array `result[]`: `id`, `name`, `status` (`active`, `pending`), `plan.name`, `name_servers[]`
3. **DNS Zone Records CRUD**:
   - `GET /zones/{zoneId}/dns_records?per_page=100`
   - **Returns**: Array `result[]`: `id`, `type` (`A`, `AAAA`, `CNAME`, `TXT`, `MX`), `name`, `content`, `ttl`, `proxied` (Boolean orange cloud)
4. **Cloudflare Pages Projects**:
   - `GET /accounts/{accountId}/pages/projects`
   - **Returns**: Array `result[]`:
     - `name`: Project slug
     - `subdomain`: `xxx.pages.dev`
     - `domains[]`: Custom hostnames
     - `source`: Git repo connection details
     - `latest_deployment`: `id`, `status` (`success`, `failure`, `active`), `created_on`, `url`
5. **Cloudflare Workers Scripts**:
   - `GET /accounts/{accountId}/workers/scripts`
   - **Returns**: Array `result[]`: `id` (script name), `modified_on`, `routes[]`
6. **Traffic Analytics (GraphQL Endpoint)**:
   - `POST /graphql`
   - **Payload**:
     ```graphql
     query($zoneTag: String!, $date: Date!) {
       viewer {
         zones(filter: { zoneTag: $zoneTag }) {
           httpRequestsAdaptiveGroups(filter: { date: $date }, limit: 100) {
             count
             sum { edgeResponseBytes }
             dimensions { datetime }
           }
         }
       }
     }
     ```
   - **Returns**: Requests count, bandwidth (bytes), threats blocked, cache status percentages.
7. **Storage Resources**:
   - KV: `GET /accounts/{accountId}/storage/kv/namespaces`
   - D1: `GET /accounts/{accountId}/d1/database`
   - R2: `GET /accounts/{accountId}/r2/buckets`

---

### 1.3 Netlify
- **Base URL**: `https://api.netlify.com/api/v1`
- **Token Type**: Netlify Personal Access Token
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
1. **User Profile**:
   - `GET /user`
   - **Returns**: `id`, `full_name`, `email`, `avatar_url`
2. **Sites Inventory**:
   - `GET /sites?page={page}&per_page=100`
   - **Pagination**: Numbered pages (`page=1, 2, ...`). Terminates when response array is empty or `< 100`.
   - **Returns**: Array of sites:
     - `id`: Site UUID (e.g. `00000000-0000-0000-0000-000000000000`)
     - `name`: Subdomain (e.g. `cool-site`)
     - `custom_domain`: Primary apex/subdomain (e.g. `example.com`)
     - `url`: Live URL
     - `ssl_url`: Secure URL
     - `screenshot_url`: Auto-generated homepage thumbnail
     - `published_deploy`: Object with active build `id`, `created_at`
     - `build_settings.repo_path`: Git repository path
     - `updated_at`: ISO8601 timestamp
3. **Deployments History**:
   - `GET /sites/{site_id}/deploys?per_page=20`
   - **Returns**: Array of deploys:
     - `id`: Deploy ID
     - `state`: `ready`, `building`, `error`, `enqueued`
     - `context`: `production`, `deploy-preview`, `branch-deploy`
     - `commit_ref`: Git SHA
     - `commit_url`: Commit link
     - `error_message`: Build failure error text if failed
     - `created_at`: ISO8601 timestamp

---

### 1.4 Railway
- **Base URL**: `https://backboard.railway.com/graphql/v2`
- **Token Types**:
  - **Account Token**: `Authorization: Bearer {token}`
  - **Project Token**: Scoped to a single project via `projectToken` header or metadata
- **Request Type**: HTTP `POST` GraphQL

#### Requests & Endpoints
1. **User Profile Query**:
   ```graphql
   query {
     me {
       id
       name
       email
       avatar
     }
   }
   ```
2. **Projects & Services Inventory (Cursor Pagination)**:
   ```graphql
   query projects($first: Int, $after: String) {
     projects(first: $first, after: $after) {
       edges {
         node {
           id
           name
           description
           createdAt
           updatedAt
           environments {
             edges { node { id name } }
           }
           services {
             edges { node { id name } }
           }
         }
       }
       pageInfo {
         hasNextPage
         endCursor
       }
     }
   }
   ```
   - **Variables**: `{"first": 100, "after": cursor}`
   - **Pagination**: Reads `pageInfo.hasNextPage` and passes `pageInfo.endCursor`.
3. **Deployments Query**:
   ```graphql
   query deployments($projectId: String!, $limit: Int) {
     deployments(input: { projectId: $projectId, limit: $limit }) {
       edges {
         node {
           id
           status # SUCCESS, FAILED, BUILDING, CRASHED, REMOVED
           createdAt
           url
           meta
         }
       }
     }
   }
   ```

---

### 1.5 Render
- **Base URL**: `https://api.render.com/v1`
- **Token Type**: Render API Key
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
1. **Workspaces / Owners**:
   - `GET /owners?limit=100`
   - **Returns**: Array of owners: `id` (e.g. `tea-xxx`, `usr-xxx`), `name`, `email`, `type` (`user`, `team`)
2. **Services List (Cursor Pagination)**:
   - `GET /services?limit=100&includePreviews=true{&cursor=xxx}`
   - **Pagination**: Uses link header / response cursor.
   - **Returns**: Array of services:
     - `service.id`: Service ID (`srv-xxx`)
     - `service.name`: Display name
     - `service.type`: `static_site`, `web_service`, `background_worker`, `cron_job`, `psql`
     - `service.repo`: Git repo URL
     - `service.branch`: Tracking branch
     - `service.url`: Public HTTPS URL
     - `service.suspended`: `true` / `false`
     - `service.serviceDetails.region`: Region (`oregon`, `frankfurt`, `singapore`, `ohio`)
     - `service.updatedAt`: ISO8601 timestamp
3. **Deployments History**:
   - `GET /services/{serviceId}/deploys?limit=20`
   - **Returns**: Array of deploys:
     - `id`: Deploy ID (`dep-xxx`)
     - `status`: `created`, `build_in_progress`, `live`, `deactivated`, `build_failed`, `canceled`
     - `commit.id`: Git SHA
     - `commit.message`: Commit message
     - `createdAt`, `finishedAt`: Timestamps

---

### 1.6 DigitalOcean App Platform
- **Base URL**: `https://api.digitalocean.com/v2`
- **Token Type**: DigitalOcean Personal Access Token
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
1. **Account Profile**:
   - `GET /account`
   - **Returns**: `account.uuid`, `account.name`, `account.email`, `account.status`, `account.droplet_limit`
2. **Apps Inventory**:
   - `GET /apps?per_page=200&page={page}`
   - **Pagination**: Numbered pages (`page=1, 2, ...`).
   - **Returns**: Array `apps[]`:
     - `id`: App UUID
     - `spec.name`: App name
     - `default_ingress`: Default `.ondigitalocean.app` domain
     - `live_url`: Configured production URL
     - `region.slug`: Hosting datacenter region (`nyc`, `sfo`, `fra`, etc.)
     - `active_deployment`: Object with active deployment ID, phase, build status
     - `updated_at`: ISO8601 timestamp
3. **App Deployments**:
   - `GET /apps/{app_id}/deployments?per_page=20`
   - **Returns**: Array `deployments[]`:
     - `id`: Deployment UUID
     - `phase`: `PENDING_BUILD`, `BUILDING`, `DEPLOYING`, `ACTIVE`, `ERROR`, `CANCELED`
     - `progress`: Percentage or step details
     - `cause`: Trigger reason (e.g. `MANUAL`, `GIT_PUSH`)
     - `created_at`: Timestamp

---

### 1.7 Heroku
- **Base URL**: `https://api.heroku.com`
- **Token Type**: Heroku API Key / OAuth Bearer Token
- **Auth Headers**:
  - `Authorization: Bearer {token}`
  - `Accept: application/vnd.heroku+json; version=3` (Mandatory for Platform API v3)

#### Requests & Endpoints
1. **Account Profile**:
   - `GET /account`
   - **Returns**: `id`, `name`, `email`
2. **Apps Inventory**:
   - `GET /apps`
   - **Returns**: Array of apps:
     - `id`: App UUID
     - `name`: App name (e.g. `my-app`)
     - `web_url`: Production URL (`https://my-app.herokuapp.com/`)
     - `git_url`: Git deployment target
     - `maintenance`: Boolean maintenance mode switch
     - `region.name`: `us`, `eu`
     - `buildpack_provided_description`: Runtime language (e.g. `Node.js`, `Python`, `Ruby`)
     - `updated_at`: Timestamp
3. **Releases / Deployments**:
   - `GET /apps/{app_id}/releases`
   - **Returns**: Array of releases:
     - `id`: Release UUID
     - `version`: Sequential release integer (e.g. `v42`)
     - `status`: `succeeded`, `pending`, `failed`
     - `description`: Deployment summary (e.g. `Deploy 1a2b3c4d`)
     - `current`: Boolean indicating if this is the active release
     - `created_at`: Timestamp

---

### 1.8 Fly.io
- **Base URL**: `https://api.machines.dev/v1`
- **Token Type**: Fly.io API Token (`FlyV1 ...`)
- **Auth Header**: `Authorization: Bearer {token}`
- **Required Metadata**: `organization` (e.g. `personal` or custom organization slug)

#### Requests & Endpoints
1. **Apps List**:
   - `GET /apps?org_slug={organization}`
   - **Returns**: Array `apps[]`:
     - `id`: App ID
     - `name`: App name (e.g. `my-app`)
     - `status`: `deployed`, `pending`, `suspended`
     - `organization.slug`: Org slug
2. **Machines (VM Instances)**:
   - `GET /apps/{app_name}/machines`
   - **Returns**: Array of Fly Machines:
     - `id`: Machine instance ID (e.g. `148ed20b604589`)
     - `name`: Unique instance name
     - `state`: `started`, `stopped`, `destroying`, `destroyed`
     - `region`: Datacenter 3-letter airport code (e.g. `iad`, `ams`, `syd`)
     - `instance_id`: Unique generation ID
     - `updated_at`: Timestamp
3. **Volumes (Persistent NVMe Storage)**:
   - `GET /apps/{app_name}/volumes`
   - **Returns**: Array of volumes: `id`, `name`, `size_gb`, `region`, `encrypted`

---

### 1.9 Firebase Hosting
- **Base URL**: `https://firebasehosting.googleapis.com/v4`
- **Token Type**: Google OAuth 2.0 Access Token
- **Scope Required**: `https://www.googleapis.com/auth/firebase.hosting`
- **Auth Header**: `Authorization: Bearer {accessToken}`
- **Required Metadata**: `projectID` (Firebase Project ID)

#### Requests & Endpoints
1. **Sites Discovery**:
   - `GET /projects/{projectID}/sites?pageSize=100`
   - **Returns**: Array `sites[]`:
     - `name`: Resource path (`projects/{projectID}/sites/{siteId}`)
     - `defaultUrl`: Default URL (`https://{siteId}.web.app`)
     - `type`: `DEFAULT_SITE` or `USER_SITE`
     - `appId`: Connected Firebase Web App ID
2. **Release Channels**:
   - `GET /projects/{projectID}/sites/{siteId}/channels?pageSize=50`
   - **Returns**: Array `channels[]`: `name` (e.g. `live`, `preview`), `url`, `release.releaseTime`
3. **Releases History**:
   - `GET /projects/{projectID}/sites/{siteId}/releases?pageSize=20`
   - **Returns**: Array `releases[]`:
     - `name`: Release resource name
     - `releaseTime`: ISO8601 timestamp
     - `releaseUser.email`: Deployer email
     - `type`: `DEPLOY`, `ROLLBACK`, `SITE_DISABLE`
     - `message`: Deployment note

---

### 1.10 AWS Amplify
- **Base URL**: `https://amplify.{region}.amazonaws.com`
- **Authentication**: AWS Signature Version 4 (HMAC-SHA256 request signing using `accessKeyID`, `secretAccessKey`, `region`, and service `amplify`).
- **Required Metadata**: `region` (e.g. `us-east-1`, `eu-west-1`), `accessKeyID`

#### Requests & Endpoints
1. **Amplify Apps Inventory**:
   - `GET /apps?maxResults=50`
   - **Returns**: Array `apps[]`:
     - `appId`: AWS Amplify App ID (e.g. `d1234567890abc`)
     - `name`: App name
     - `description`: App description
     - `defaultDomain`: Default domain (e.g. `d1234567890abc.amplifyapp.com`)
     - `repository`: Connected repository URL
     - `productionBranch.branchName`: Production branch name
2. **Branches List**:
   - `GET /apps/{appId}/branches`
   - **Returns**: Array `branches[]`:
     - `branchName`: Branch name (e.g. `main`, `develop`)
     - `stage`: `PRODUCTION`, `BETA`, `DEVELOPMENT`, `EXPERIMENTAL`
     - `activeJobId`: Current running job ID
     - `totalExecutions`: Total builds executed
3. **Branch Jobs / Builds History**:
   - `GET /apps/{appId}/branches/{branchName}/jobs?maxResults=50`
   - **Returns**: Array `jobSummaries[]`:
     - `jobId`: Sequential build job ID
     - `status`: `PENDING`, `PROVISIONING`, `RUNNING`, `FAILED`, `SUCCEED`, `CANCELLED`
     - `startTime`, `endTime`: ISO8601 timestamps

---

# 2. Domain Registrars (8 Integrations)

---

### 2.1 Name.com
- **Base URL**: `https://api.name.com`
- **Credentials Required**:
  - `username`: Name.com account username
  - `token`: Production API Token
- **Auth Header**: `Authorization: Basic {base64(username + ":" + token)}`

#### Domain List Fetch
- **Endpoint**: `GET /core/v1/domains?perPage=250&page={page}`
- **Pagination**: 1-indexed page integer. Loop continues while `nextPage > page`. Maximum 200 pages.
- **Fields Extracted**:
  - Domain Name: `domainName` ?? `domain`
  - Status: `status`
  - Created Date: `createDate`
  - Expiry Date: `expireDate`
  - Auto-Renew: `autorenewEnabled` ?? `autoRenew` (Boolean)
  - Locked: `locked` (Boolean)
  - WHOIS Privacy: `privacyEnabled` (Boolean)
  - Nameservers: `nameservers[]` (Array of host strings)

---

### 2.2 Namecheap
- **Base URL**: `https://api.namecheap.com`
- **Credentials Required**:
  - `ApiKey`: Namecheap API key
  - `ApiUser` & `UserName`: Account username
  - `ClientIp`: **Whitelisted Public IPv4 Address** (Must match the IP configured in Namecheap API settings)
- **Auth Format**: Query parameters added to the URL. No auth headers used.

#### Domain List Fetch
- **Endpoint**: `GET /xml.response?Command=namecheap.domains.getList&ListType=ALL&PageSize=100&Page={page}&ApiUser={user}&ApiKey={key}&UserName={user}&ClientIp={ip}`
- **Response Format**: **XML** (`ApiResponse -> CommandResponse -> DomainGetListResult -> Domain`)
- **Pagination**: Numbered pages (`Page=1, 2, ...`). Evaluates `<TotalItems>` and `<PageSize>`. Stops when `page * pageSize >= TotalItems`.
- **Fields Extracted from XML Attributes**:
  - Domain Name: `Name`
  - Status: `IsExpired == "true" ? "Expired" : "Active"`
  - Created Date: `Created` (Parsed with `MM/dd/yyyy`)
  - Expiry Date: `Expires`
  - Auto-Renew: `AutoRenew == "true"`
  - Locked: `IsLocked == "true"`
  - WHOIS Privacy: `WhoisGuard.uppercased() in ["ENABLED", "WITHHELD"]`
  - IsOurDNS: `IsOurDNS` (Boolean)

---

### 2.3 Porkbun
- **Base URL**: `https://api.porkbun.com/api/json/v3`
- **Credentials Required**:
  - `apiKey`: Porkbun API key
  - `secretApiKey`: Porkbun Secret key
- **Auth Headers**:
  - `X-API-Key: {apiKey}`
  - `X-Secret-API-Key: {secretApiKey}`

#### Domain List Fetch
- **Endpoint**: `GET /domain/listAll?start={start}`
- **Pagination**: Offset parameter `start` in increments of 1,000 (`start=0, 1000, 2000, ...`).
  - If `items.count < 1000`: pagination finishes.
  - If a 1,000-item page yields 0 new unique domains: aborts to prevent infinite loop.
- **Validation**: Requires JSON `status == "SUCCESS"`.
- **Fields Extracted**:
  - Domain Name: `domain` ?? `name`
  - Status: `status`
  - Created Date: `createDate` ?? `createdAt`
  - Expiry Date: `expireDate` ?? `expirationDate`
  - Auto-Renew: `autoRenew` (Boolean: 1/0 or true/false)
  - Security Lock: `securityLock` ?? `locked` (Boolean)
  - Privacy: `whoisPrivacy` ?? `privacy` (Boolean)
  - Nameservers: `nameservers[]`

---

### 2.4 Spaceship
- **Base URL**: `https://spaceship.dev/api`
- **Credentials Required**:
  - `apiKey`: Spaceship API Key
  - `apiSecret`: Spaceship API Secret
- **Auth Headers**:
  - `X-API-Key: {apiKey}`
  - `X-API-Secret: {apiSecret}`

#### Domain List Fetch
- **Endpoint**: `GET /v1/domains?take=100&skip={skip}`
- **Pagination**: Offset/limit paging (`take=100`, `skip=0, 100, 200, ...`). Stops when `skip + items.count >= total`.
- **Fields Extracted**:
  - Domain Name: `unicodeName` ?? `name` ?? `domain`
  - Status: `lifecycleStatus` ?? `status`
  - Created Date: `registrationDate`
  - Expiry Date: `expirationDate`
  - Auto-Renew: `autoRenew` (Boolean)
  - Locked: Checks if `eppStatuses[]` contains `"transferProhibited"` (case-insensitive)
  - Privacy: `privacyProtection.contactForm == true` OR `privacyProtection.level != "none"`
  - Nameservers: `nameservers.hosts[]`
  - Verification: `verificationStatus`

---

### 2.5 Dynadot
- **Base URL**: `https://api.dynadot.com`
- **Credentials Required**:
  - `apiKey`: Dynadot API Key
- **Auth Format**: Query parameter `key={apiKey}` added to URL.

#### Domain List Fetch
- **Endpoint**: `GET /api3.json?command=list_domain&count_per_page=100&page_index={page}&key={apiKey}`
- **Pagination**: 0-indexed page index (`page_index=0, 1, 2, ...`). Stops when `items.count < 100`. Employs pipe-separated sorted domain signature check to prevent loops.
- **Validation**: Requires `ListDomainInfoResponse.Status == "success"`.
- **Fields Extracted**:
  - Domain Name: `Name` ?? `name` ?? `Domain`
  - Status: `Status`
  - Created Date: `Registration` ?? `CreateDate`
  - Expiry Date: `Expiration` ?? `ExpireDate`
  - Auto-Renew: `RenewOption` ?? `AutoRenew`
  - Locked: `Locked` ?? `lock`
  - Privacy: `Privacy` ?? `privacy`
  - Nameservers: `NameServers[]`

---

### 2.6 NameSilo
- **Base URL**: `https://www.namesilo.com`
- **Credentials Required**:
  - `apiKey`: NameSilo API Key
- **Protocol Rule**: **Strict GET-only**. NameSilo rejects all POST/PUT/DELETE requests.
- **Auth & Query Format**: `key={apiKey}&version=1&type=json`

#### Domain List Fetch
- **Endpoint**: `GET /api/listDomains?pageSize=100&page={page}&version=1&type=json&key={apiKey}`
- **Pagination**: 1-indexed page integer (`page=1, 2, ...`). Reads `reply.pager.total`. Stops when loaded count matches `total`.
- **Validation**: `reply.code` must strictly equal `"300"`. Any other code indicates failure.
- **Fields Extracted**:
  - Domain Name: `domain` ?? `name`
  - Status: `status`
  - Created Date: `created` ?? `created_at`
  - Expiry Date: `expires` ?? `expiration`
  - Auto-Renew: `auto_renew` ?? `autoRenew` (Boolean)
  - Locked: `locked` (Boolean)
  - Privacy: `private` ?? `privacy` (Boolean)
  - Nameservers: `nameservers[]`

---

### 2.7 Gandi
- **Base URL**: `https://api.gandi.net`
- **Credentials Required**:
  - `personalAccessToken`: Gandi Personal Access Token (PAT)
  - `organization`: Optional sharing/organization UUID
- **Auth Header**: `Authorization: Bearer {personalAccessToken}`

#### Domain List Fetch
- **Endpoint**: `GET /v5/domain/domains?per_page=100&page={page}`
- **Pagination**: 1-indexed page integer (`page=1, 2, ...`). Terminates when page returns `< 100` items.
- **Fields Extracted**:
  - Domain Name: `fqdn` ?? `name`
  - Status: Joined string of `status[]` array
  - Created Date: `dates_registry_created_at` ?? `dates.registry_created_at`
  - Expiry Date: `dates_registry_ends_at` ?? `dates.registry_ends_at`
  - Auto-Renew: `autorenew` (Boolean)
  - Locked: Checks if array `status[]` contains `"transferProhibited"`
  - Privacy: `is_private` ?? `privacy` (Boolean)
  - Nameservers: `nameserver.hosts[]`
  - Sharing ID: `sharing_id`

---

### 2.8 GoDaddy
- **Base URL**: `https://api.godaddy.com`
- **Credentials Required**:
  - `apiKey`: GoDaddy Developer Key
  - `apiSecret`: GoDaddy Developer Secret
- **Auth Header**: `Authorization: sso-key {apiKey}:{apiSecret}`

#### Domain List Fetch
- **Endpoint**: `GET /v1/domains?limit=1000&includes=nameServers{&marker=xxx}`
- **Pagination**: Marker-based cursor pagination. Sets `marker={lastDomainName}` for subsequent pages. Terminates when `items.count < 1000` or marker repeats.
- **Fields Extracted**:
  - Domain Name: `domain` ?? `name`
  - Status: `status`
  - Created Date: `createdAt` ?? `created`
  - Expiry Date: `expires` ?? `expiresAt`
  - Auto-Renew: `renewAuto` ?? `autoRenew` (Boolean)
  - Locked: `locked` (Boolean)
  - Privacy: `privacy` (Boolean)
  - Nameservers: `nameServers[]`
  - Domain ID: `domainId`

---

# 3. Site Services (9 Integrations)

---

### 3.1 Google Search Console
- **Base URL**: `https://www.googleapis.com/webmasters/v3` and `https://searchconsole.googleapis.com/v1`
- **Auth Mechanism**: OAuth 2.0 PKCE with scope `https://www.googleapis.com/auth/webmasters.readonly`
- **Auth Header**: `Authorization: Bearer {accessToken}`

#### Requests & Endpoints
1. **Properties List**:
   - `GET https://www.googleapis.com/webmasters/v3/sites`
   - **Returns**: Array `siteEntry[]`:
     - `siteUrl`: Either URL prefix (`https://example.com/`) or domain property (`sc-domain:example.com`)
     - `permissionLevel`: `siteOwner`, `siteFullUser`, `siteRestrictedUser`, `siteUnverifiedUser`
2. **Search Performance (Aggregate & Dimension Breakdowns)**:
   - `POST https://www.googleapis.com/webmasters/v3/sites/{encodedSiteUrl}/searchAnalytics/query`
   - *Note on encoding*: URL prefixes require URL percent encoding (e.g. `https%3A%2F%2Fexample.com%2F`), domain properties encode as `sc-domain%3Aexample.com`.
   - **Payload**:
     ```json
     {
       "startDate": "2026-08-18",
       "endDate": "2026-09-15",
       "dimensions": ["query"], // Options: date, hour, query, page, country, device, searchAppearance
       "type": "web",           // Options: web, image, video, news, discover, googleNews
       "aggregationType": "auto", // Options: auto, byPage, byProperty
       "dataState": "all",      // Options: all, final, hourly_all
       "rowLimit": 25000,
       "startRow": 0,
       "dimensionFilterGroups": [
         {
           "groupType": "and",
           "filters": [
             {
               "dimension": "country",
               "operator": "equals", // Options: contains, equals, notContains, notEquals, includingRegex, excludingRegex
               "expression": "usa"
             }
           ]
         }
       ]
     }
     ```
   - **Returns**: Array `rows[]`:
     - `keys[]`: Dimension values matching requested order
     - `clicks`: Cumulative click count
     - `impressions`: Search result impression count
     - `ctr`: Click-through rate (float 0.0 to 1.0)
     - `position`: Average rank position (1.0 = top of Google search)
3. **Sitemaps List**:
   - `GET https://www.googleapis.com/webmasters/v3/sites/{encodedSiteUrl}/sitemaps`
   - **Returns**: Array `sitemap[]`: `path`, `lastSubmitted`, `isPending`, `isSitemapsIndexFile`, `type`, `contents[].type`, `contents[].submitted`, `contents[].indexed`
4. **URL Inspection (Realtime Index Status)**:
   - `POST https://searchconsole.googleapis.com/v1/urlInspection/index:inspect`
   - **Payload**:
     ```json
     {
       "inspectionUrl": "https://example.com/page",
       "siteUrl": "sc-domain:example.com",
       "languageCode": "en-US"
     }
     ```
   - **Returns**: `inspectionResult.indexStatusResult`:
     - `verdict`: `PASS`, `NEUTRAL`, `FAIL`
     - `coverageState`: Indexing outcome (e.g. `Submitted and indexed`, `Crawled - currently not indexed`)
     - `robotsTxtState`: `ALLOWED`, `DISALLOWED`
     - `indexingState`: `INDEXING_ALLOWED`, `BLOCKED_BY_META_TAG`
     - `lastCrawlTime`: ISO8601 timestamp
     - `pageFetchState`: `SUCCESSFUL`, `SOFT_404`, `NOT_FOUND`
     - `googleCanonical` vs `userCanonical`

---

### 3.2 Google Analytics 4 (GA4)
- **Base URLs**:
  - Admin API: `https://analyticsadmin.googleapis.com/v1beta`
  - Data Reporting API: `https://analyticsdata.googleapis.com/v1beta`
- **Auth Mechanism**: OAuth 2.0 PKCE with scope `https://www.googleapis.com/auth/analytics.readonly`
- **Auth Header**: `Authorization: Bearer {accessToken}`

#### Requests & Endpoints
1. **Account & Properties Discovery**:
   - `GET https://analyticsadmin.googleapis.com/v1beta/accountSummaries?pageSize=200`
   - **Returns**: `accountSummaries[].propertySummaries[]`:
     - `property`: Resource path (`properties/123456789`)
     - `displayName`: Property label
     - `propertyType`: `PROPERTY_TYPE_ORDINARY`
2. **Data Streams Discovery**:
   - `GET https://analyticsadmin.googleapis.com/v1beta/properties/{propertyId}/dataStreams?pageSize=200`
   - **Returns**: Array `dataStreams[]`:
     - `name`: Stream path
     - `type`: `WEB_DATA_STREAM`, `ANDROID_APP_DATA_STREAM`, `IOS_APP_DATA_STREAM`
     - `webStreamData.measurementId`: `G-XXXXXXXXXX`
     - `webStreamData.defaultUri`: Website origin URL
3. **Traffic Reports Execution (`runReport`)**:
   - `POST https://analyticsdata.googleapis.com/v1beta/properties/{propertyId}:runReport`
   - **Payload (30-Day Breakdown Example)**:
     ```json
     {
       "dateRanges": [{"startDate": "30daysAgo", "endDate": "today"}],
       "dimensions": [
         {"name": "sessionDefaultChannelGroup"},
         {"name": "sessionSource"},
         {"name": "sessionMedium"}
       ],
       "metrics": [
         {"name": "activeUsers"},
         {"name": "sessions"},
         {"name": "screenPageViews"},
         {"name": "engagementRate"},
         {"name": "eventCount"},
         {"name": "averageSessionDuration"}
       ],
       "orderBys": [
         {"dimension": {"dimensionName": "sessionDefaultChannelGroup"}, "desc": false}
       ],
       "keepEmptyRows": true
     }
     ```
   - **Returns**:
     - `dimensionHeaders[]`, `metricHeaders[]`
     - `rows[]`: Array of `dimensionValues[].value` and `metricValues[].value`
     - `rowCount`: Total count across high-cardinality pages
4. **Realtime Users (`runRealtimeReport`)**:
   - `POST https://analyticsdata.googleapis.com/v1beta/properties/{propertyId}:runRealtimeReport`
   - **Payload**:
     ```json
     {
       "dimensions": [{"name": "minutesAgo"}],
       "metrics": [{"name": "activeUsers"}, {"name": "eventCount"}],
       "limit": "60",
       "returnPropertyQuota": true
     }
     ```
   - **Returns**: Active user counts by minute for the last 30 minutes.

---

### 3.3 PageSpeed Insights & Chrome UX Report (CrUX)
- **Base URLs**:
  - PageSpeed API: `https://www.googleapis.com/pagespeedonline/v5`
  - CrUX API: `https://chromeuxreport.googleapis.com/v1`
- **Auth**: Google Cloud API Key in query parameter: `key={apiKey}`

#### Requests & Endpoints
1. **Lighthouse Lab Audit**:
   - `GET https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url={siteUrl}&strategy={mobile|desktop}&category=performance&category=accessibility&category=best-practices&category=seo&key={apiKey}`
   - **Returns**: `lighthouseResult`:
     - **Category Scores (0 - 100)**:
       - `categories.performance.score * 100`
       - `categories.accessibility.score * 100`
       - `categories.best-practices.score * 100`
       - `categories.seo.score * 100`
     - **Lab Audits**:
       - `audits["largest-contentful-paint"].numericValue` (ms)
       - `audits["interaction-to-next-paint"].numericValue` (ms)
       - `audits["cumulative-layout-shift"].numericValue` (layout score)
       - `audits["first-contentful-paint"].numericValue` (ms)
       - `audits["server-response-time"].numericValue` (ms)
       - `audits["total-blocking-time"].numericValue` (ms)
       - `audits["speed-index"].numericValue` (ms)
2. **Field Real-User Core Web Vitals (CrUX Record)**:
   - `POST https://chromeuxreport.googleapis.com/v1/records:queryRecord?key={apiKey}`
   - **Payload**: `{"url": "https://example.com"}`
   - **Returns**: `record.metrics`:
     - `largest_contentful_paint.percentiles.p75` (Field LCP ms)
     - `interaction_to_next_paint.percentiles.p75` (Field INP ms)
     - `cumulative_layout_shift.percentiles.p75` (Field CLS ratio)
     - `first_contentful_paint.percentiles.p75` (Field FCP ms)
     - `experimental_time_to_first_byte.percentiles.p75` (Field TTFB ms)
3. **Historical Field Progression (CrUX History Record)**:
   - `POST https://chromeuxreport.googleapis.com/v1/records:queryHistoryRecord?key={apiKey}`
   - **Payload**: `{"url": "https://example.com", "collectionPeriodCount": 40}`
   - **Returns**: 40 historic 28-day sliding collection periods plotting `percentilesTimeseries.p75s[]`.

---

### 3.4 Bing Webmaster Tools
- **Base URL**: `https://ssl.bing.com/webmaster/api.svc/json`
- **Credentials Required**: Bing Webmaster API Key
- **Auth Format**: Query parameter `apikey={apiKey}`

#### Requests & Endpoints
1. **Sites Inventory**:
   - `GET /GetUserSites?apikey={apiKey}`
   - **Returns**: Array under `d[]` or `sites[]`: `Url`, `IsVerified` (Boolean)
2. **Search Traffic Statistics (30 Days)**:
   - `GET /GetRankAndTrafficStats?siteUrl={siteUrl}&apikey={apiKey}`
   - **Date Format**: Microsoft JSON Date: `/Date(1704067200000)/`
   - **Returns**: Array `d[]`:
     - `Date`: Timestamp
     - `Clicks`: Click count
     - `Impressions`: Impression count
3. **Crawl Statistics**:
   - `GET /GetCrawlStats?siteUrl={siteUrl}&apikey={apiKey}`
   - **Returns**: Array `d[]`:
     - `CrawledPages`: Pages crawled successfully
     - `CrawlErrors`: HTTP failure count
     - `InIndex`: Total indexed pages
     - `InLinks`: Total detected backlinks
     - `Code4xx`: Client errors count
     - `Code5xx`: Server errors count
     - `BlockedByRobotsTxt`: Blocked page count
4. **Keywords & Queries**:
   - `GET /GetQueryStats?siteUrl={siteUrl}&apikey={apiKey}`
   - **Returns**: `Query`, `Impressions`, `Clicks`, `AvgClickPosition`, `AvgImpressionPosition`

---

### 3.5 Microsoft Clarity
- **Base URL**: `https://www.clarity.ms/export-data/api/v1`
- **Credentials Required**: Clarity API Export Token
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
- **Live Behavioral Insights**:
  - `GET /project-live-insights?numOfDays={1-3}&dimension1={dim}&dimension2={dim}`
  - **Supported Dimensions**: `Browser`, `Device`, `Country/Region`, `OS`, `Source`, `Medium`, `Campaign`, `Channel`, `URL`
  - **Lookback Window**: Maximum 3 days
  - **Returns**: Array of metric groups with `metricName` and `information[]`:
    - `URL`: Page URL
    - `SessionCount`: Total sessions
    - `ScrollDepth`: Average scroll depth percentage
    - `DeadClicks`: Number of clicks with no page effect
    - `RageClicks`: Frustrated repeated clicks count
    - `QuickBacks`: Immediate back button navigation count
    - `ExcessiveScrolling`: Frantic scrolling count
    - `JavaScriptErrors`: Frontend JS exception count

---

### 3.6 Plausible Analytics
- **Base URL**: `https://plausible.io/api/v2`
- **Credentials Required**: Plausible Stats API Key
- **Auth Header**: `Authorization: Bearer {token}`
- **Required Metadata**: `siteID` (e.g. `example.com`)

#### Requests & Endpoints
- **Universal Query Endpoint**:
  - `POST /query`
  - **Payload**:
    ```json
    {
      "site_id": "example.com",
      "date_range": "30d", // Or [startDate, endDate]
      "dimensions": ["visit:source"], // Options: time:day, visit:source, event:page, event:goal, visit:country, visit:device
      "metrics": ["visitors", "visits", "pageviews", "bounce_rate", "visit_duration"],
      "filters": [],
      "include": {"total_rows": true} // Mandatory for pagination detection
    }
    ```
  - **Returns**:
    - `results[].dimensions[]`: Dimension labels
    - `results[].metrics[]`: Parallel array of calculated metric values
    - `meta.total_rows`: Total rows in dataset for pagination

---

### 3.7 Umami Analytics (Cloud & Self-Hosted)
- **Base URLs**:
  - **Umami Cloud**: `https://api.umami.is/v1`
  - **Self-Hosted**: User-defined (e.g. `https://analytics.example.com/api`)
- **Auth Headers**:
  - Cloud: `x-umami-api-key: {apiKey}`
  - Self-Hosted: `Authorization: Bearer {tokenOrJwt}`

#### Requests & Endpoints
1. **Account Identity Verification**:
   - `GET {base}/me`
   - **Returns**: `user.id`, `user.username`, `user.createdAt`
2. **Websites Discovery**:
   - `GET {base}/websites?page={page}&pageSize=100&includeTeams=true`
   - **Returns**: Array `data[]` or `websites[]`:
     - `id`: Website UUID
     - `name`: Site label
     - `domain`: Domain string
     - `updatedAt`: Timestamp
3. **Overview Statistics**:
   - `GET {base}/websites/{websiteId}/stats?startAt={startMs}&endAt={endMs}`
   - **Returns**:
     - `pageviews`: Total pageview hits
     - `visitors`: Unique visitors count
     - `visits`: Total user sessions
     - `bounces`: Single-page bounce sessions
     - `totaltime`: Cumulative time on site (seconds)
4. **Dimension Metrics**:
   - `GET {base}/websites/{websiteId}/metrics?startAt={startMs}&endAt={endMs}&type={type}`
   - **Types Supported**: `path`, `entry`, `exit`, `title`, `query`, `referrer`, `channel`, `domain`, `country`, `region`, `city`, `browser`, `os`, `device`, `language`, `screen`, `event`, `hostname`, `tag`, `distinctId`
   - **Returns**: Array of `{x: "Label", y: count}`
5. **Active Realtime Visitors**:
   - `GET {base}/websites/{websiteId}/active`
   - **Returns**: Realtime active user count (`x: count`)
6. **Pageviews Series**:
   - `GET {base}/websites/{websiteId}/pageviews?startAt={startMs}&endAt={endMs}&unit=day`
   - **Returns**: Array of `{x: "YYYY-MM-DD", y: pageviews}`

---

### 3.8 UptimeRobot
- **Base URL**: `https://api.uptimerobot.com/v2`
- **Credentials Required**: Read-Only API Key (`ur...`)
- **Protocol & Headers**:
  - Method: HTTP `POST`
  - Content-Type: `application/x-www-form-urlencoded`

#### Requests & Endpoints
1. **Monitors Overview & Snapshot**:
   - `POST /getMonitors`
   - **Form Body**:
     ```text
     api_key={apiKey}&format=json&logs=1&logs_limit=1&response_times=1&custom_uptime_ratios=1-7-30&limit=50&offset={offset}
     ```
   - **Numeric Status Mapping**:
     - `0`: Paused
     - `1`: Not checked yet
     - `2`: **Up** (Operational)
     - `8`: Seems down
     - `9`: **Down**
   - **Returns**: Array `monitors[]`:
     - `id`: Monitor ID
     - `friendly_name`: Monitor label
     - `url`: Target URL
     - `status`: Status integer
     - `custom_uptime_ratio`: Hyphen-delimited ratio string (e.g. `"99.98-99.95-99.91"` mapping to 24h, 7d, 30d uptime percentages)
     - `average_response_time`: Response time (ms)
     - `logs[]`: Latest log entry (`type`, `datetime`, `duration`, `reason`)
2. **Deep Monitor Logs & Historical Response Times**:
   - `POST /getMonitors`
   - **Form Body**:
     ```text
     api_key={apiKey}&format=json&monitors={monitorId}&logs=1&logs_start_date={startSec}&logs_end_date={endSec}&response_times=1&response_times_start_date={startSec}&response_times_end_date={endSec}&response_times_average=30&alert_contacts=1&mwindows=1&ssl=1
     ```
   - **Returns**: 30-minute interval response time samples (`datetime`, `value`), detailed event logs, SSL expiry days.
3. **Account Quotas**:
   - `POST /getAccountDetails`
   - **Returns**: Monitor limits, check intervals, active monitors count.

---

### 3.9 Better Stack
- **Base URL**: `https://uptime.betterstack.com`
- **Credentials Required**: Better Stack API Token
- **Auth Header**: `Authorization: Bearer {token}`

#### Requests & Endpoints
1. **Monitors Inventory (JSON:API Standard)**:
   - `GET /api/v2/monitors`
   - **Pagination**: RFC 5988 Linked pagination. Follows `pagination.next` URL until null.
   - **Returns**: Array `data[]`:
     - `id`: Monitor ID
     - `attributes.pronounceable_name`: Label
     - `attributes.url`: Target URL
     - `attributes.status`: `up`, `down`, `paused`, `pending`
     - `attributes.check_frequency`: Poll cadence in seconds (e.g. `30`, `60`, `180`)
     - `attributes.last_checked_at`: ISO8601 timestamp
     - `attributes.monitor_type`: `status`, `keyword`, `ping`, `tcp`
2. **Response-Time Breakdown by Global Probe Region**:
   - `GET /api/v2/monitors/{monitorId}/response-times?from={YYYY-MM-DD}&to={YYYY-MM-DD}`
   - **Returns**: Samples partitioned by geographical probe location under `data.attributes.regions[]`:
     - `region`: Probe location (e.g. `us`, `eu`, `apac`)
     - `response_times[]`:
       - `at`: Timestamp
       - `response_time`: Total round-trip latency (ms)
       - `name_lookup_time`: DNS resolution time (ms)
       - `connection_time`: TCP handshake time (ms)
       - `tls_handshake_time`: TLS negotiation time (ms)
       - `data_transfer_time`: Content transfer latency (ms)
3. **SLA Uptime Percentages**:
   - `GET /api/v2/monitors/{monitorId}/sla?from={YYYY-MM-DD}&to={YYYY-MM-DD}`
   - **Returns**: `data.attributes.availability`: Uptime ratio percentage across date range.
4. **Incidents History**:
   - `GET /api/v3/incidents?monitor_id={monitorId}&from={YYYY-MM-DD}&to={YYYY-MM-DD}&per_page=50`
   - **Returns**: Array `data[]`:
     - `id`: Incident UUID
     - `attributes.name`: Incident title
     - `attributes.status`: `Resolved`, `Ongoing`
     - `attributes.started_at`, `attributes.resolved_at`
     - `attributes.cause`: Root cause description (e.g. `HTTP 502 Bad Gateway`, `Connection Timeout`)
