---
stage: Secure
group: Dynamic Analysis
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: reference, howto
---

# Browserker **ULTIMATE**

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/323423) in GitLab 13.10.

WARNING:
This product is in an [alpha](https://about.gitlab.com/handbook/product/gitlab-the-product/#alpha) stage and considered unstable.
Features may be subject to change or breakage across future releases.

Browserker is a crawler engine built by GitLab to test Single Page Applications (SPAs) as well as traditional web applications.
Due to the reliance of modern web applications on JavaScript, handling SPAs or applications that are dependent on JavaScript is paramount to ensuring proper coverage of an application for Dynamic Application Security Testing (DAST).

Browserker crawls by loading the target application into a specially instrumented browser. A snapshot of the page is taken prior to a search to find any actions that a user might perform,
such as clicking on a link or filling in a form. For each action found, Browserker will execute it, take a new snapshot and determine what in the page changed from the previous snapshot.
Crawling continues by taking more snapshots and finding subsequent actions. 

The benefit of crawling by following user actions in a browser is that Browserker can interact with the target application much like a real user would, identifying complex flows that traditional web crawlers don’t understand. This results in better coverage of both the user-facing website and their backend APIs.



## Enable Browserker

Browserker is an extension to the GitLab DAST product. DAST should be included in the CI configuration and Browserker enabled using environment variables:

- Install the DAST [prerequisites](./index.md#prerequisites)
- Include the [DAST CI template](./index.md#include-the-dast-template)
- Set the [target website](./index.md#template-options)
- Set the environment variable `DAST_BROWSERKER_SCAN` to `true`
 
An example configuration might look like the following:

```yaml
include:
  - template: DAST.gitlab-ci.yml

variables:
  DAST_WEBSITE: https://example.com
  DAST_BROWSERKER_SCAN: true
```



