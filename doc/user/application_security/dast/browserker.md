---
stage: Secure
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, howto
---

# Browserker **(ULTIMATE)**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/323423) in GitLab 13.10.

WARNING:
This product is an early access and is considered a [beta](https://about.gitlab.com/handbook/product/gitlab-the-product/#beta) feature.

Browserker is a crawler engine built by GitLab to test Single Page Applications (SPAs) as well as traditional web applications.
Due to the reliance of modern web applications on JavaScript, handling SPAs or applications that are dependent on JavaScript is paramount to ensuring proper coverage of an application for Dynamic Application Security Testing (DAST).

Browserker crawls by loading the target application into a specially instrumented Chromium browser. A snapshot of the page is taken prior to a search to find any actions that a user might perform,
such as clicking on a link or filling in a form. For each action found, Browserker will execute it, take a new snapshot and determine what in the page changed from the previous snapshot.
Crawling continues by taking more snapshots and finding subsequent actions.

The benefit of crawling by following user actions in a browser is that Browserker can interact with the target application much like a real user would, identifying complex flows that traditional web crawlers don’t understand. This results in better coverage of both the user-facing website and their backend APIs.

## Enable Browserker

Browserker is an extension to the GitLab DAST product. DAST should be included in the CI configuration and Browserker enabled using environment variables:

- Install the DAST [prerequisites](index.md#prerequisite)
- Include the [DAST CI template](index.md#include-the-dast-template)
- Set the target website using the `DAST_WEBSITE` environment variable
- Set the environment variable `DAST_BROWSERKER_SCAN` to `true`
 
An example configuration might look like the following:

```yaml
include:
  - template: DAST.gitlab-ci.yml

variables:
  DAST_WEBSITE: https://example.com
  DAST_BROWSERKER_SCAN: true
```

### Available variables

Browserker can be configured using CI/CD variables.

| CI/CD variable                       | Type            | Example                           | Description | 
|--------------------------------------| ----------------| --------------------------------- | ------------|
| `DAST_BROWSERKER_SCAN`               | boolean         | `true`                            | Configures DAST to use the Browserker crawler engine. |
| `DAST_BROWSERKER_ALLOWED_HOSTS`      | List of strings | `site.com,another.com`            | Hostnames included in this variable are considered in scope when crawled. By default the `DAST_WEBSITE` hostname will be included into the allowed hosts list. |
| `DAST_BROWSERKER_EXCLUDED_HOSTS`     | List of strings | `site.com,another.com`            | Hostnames included in this variable are considered excluded and connections will be forcibly dropped. |
| `DAST_BROWSERKER_IGNORED_HOSTS`      | List of strings | `site.com,another.com`            | Hostnames included in this variable will be allowed to access but not reported against. | 
| `DAST_BROWSERKER_MAX_ACTIONS`        | number          | `10000`                           | The maximum number of actions (e.g. clicking a link, filling a form) that the crawler will execute. |
| `DAST_BROWSERKER_MAX_DEPTH`          | number          | `10`                              | The maximum number of chained actions that the crawler will take. For example, `Click -> Form Fill -> Click` would be a depth of three. |
| `DAST_BROWSERKER_NUMBER_OF_BROWSERS` | number          | `3`                               | The maximum number of concurrent browser instances to use. For shared runners on GitLab.com it is recommended to not choose a value over three. Private runners with more resources may benefit from a higher number, but will likely produce little benefit after five to seven instances. |
| `DAST_BROWSERKER_COOKIES`            | dictionary      | `abtesting_group:3,region:locked` | A cookie name and value that should be added to every request. |
| `DAST_AUTH_URL`                      | string          | `https://example.com/sign-in`     | URL of page that hosts the sign-in form. |
| `DAST_USERNAME`                      | string          | `user123`                         | The username to enter into the username field on the sign-in HTML form. |
| `DAST_PASSWORD`                      | string          | `p@55w0rd`                        | The password to enter into the password field on the sign-in HTML form. |
| `DAST_USERNAME_FIELD`                | selector        | `id:user`                         | A selector describing the username field on the sign-in HTML form. |
| `DAST_PASSWORD_FIELD`                | selector        | `css:.password-field`             | A selector describing the password field on the sign-in HTML form. | 
| `DAST_SUBMIT_FIELD`                  | selector        | `xpath://input[@value='Login']`   | A selector describing the element that when clicked submits the login form or the password form of a multi-page login process. |
| `DAST_FIRST_SUBMIT_FIELD`            | selector        | `.submit`                         | A selector describing the element that when clicked submits the username form of a multi-page login process. |

The [DAST variables](index.md#available-variables) `SECURE_ANALYZERS_PREFIX`, `DAST_WEBSITE`, `DAST_FULL_SCAN_ENABLED`, `DAST_AUTO_UPDATE_ADDONS`, `DAST_EXCLUDE_RULES`, `DAST_REQUEST_HEADERS`, `DAST_HTML_REPORT`, `DAST_MARKDOWN_REPORT`, `DAST_XML_REPORT`,
`DAST_INCLUDE_ALPHA_VULNERABILITIES`, `DAST_ZAP_CLI_OPTIONS`, and `DAST_ZAP_LOG_CONFIGURATION` are also compatible with Browserker scans.   

#### Selectors

Selectors are used by environment variables to specify the location of an element displayed on a page in a browser.
Selectors have the format `type`:`search string`. Browserker will search for the selector using the search string based on the type.

| Selector type | Example                        | Description |
| ------------- | ------------------------------ | ----------- |
| `css`         | `css:.password-field`          | Searches for a HTML element having the supplied CSS selector. Selectors should be as specific as possible for performance reasons. |
| `id`          | `id:element`                   | Searches for a HTML element with the provided element ID. |
| `name`        | `name:element`                 | Searches for a HTML element with the provided element name. |
| `xpath`       | `xpath://*[@id="my-button"]/a` | Searches for a HTML element with the provided XPath. Note that XPath searches are expected to be less performant than other searches. |
| none provided | `a.click-me`                   | Defaults to searching using a CSS selector. |

## Vulnerability detection

While Browserker provides users with a efficient crawler of modern web applications, vulnerability detection is still managed by the standard DAST/Zed Attack Proxy (ZAP) solution.

Browserker runs the target website in a browser with DAST/ZAP configured as the proxy server. This ensures that all requests and responses made by the browser are passively scanned by DAST/ZAP.
When running a full scan, active vulnerability checks executed by DAST/ZAP do not use a browser. This difference in how vulnerabilities are checked can cause issues that require certain features of the target website to be disabled to ensure the scan works as intended.

For example, for a target website that contains forms with Anti-CSRF tokens, a passive scan will scan as intended because the browser displays pages/forms as if a user is viewing the page.
However, active vulnerability checks run in a full scan will not be able to submit forms containing Anti-CSRF tokens. It is recommended in cases such as this to disable Anti-CSRF tokens when running a full scan.

The DAST team is looking into full scan limitations with a solution set to be identified in the product roadmap.

## Managing scan time

It is expected that running Browserker compared to the normal GitLab DAST solution will result in better coverage for many web applications.
This can come at a cost of increased scan time.

The coverage/scan time trade-off can be managed by the user with the following measures:

- Limiting the number of actions executed by the browser with the [variable](#available-variables) `DAST_BROWSERKER_MAX_ACTIONS`. The default is `10,000`.
- Limiting the page depth that Browserker will check coverage on with the [variable](#available-variables) `DAST_BROWSERKER_MAX_DEPTH`. Browserker uses a breadth-first search strategy, so pages with smaller depth are crawled first. The default is `10`.
- Vertically scaling the runner and using a higher number of browsers with [variable](#available-variables) `DAST_BROWSERKER_NUMBER_OF_BROWSERS`. The default is `3`.

## AJAX Crawler

The AJAX Crawler is not supported by Browserker.

## API Scanning

API scanning is not supported by Browserker.
