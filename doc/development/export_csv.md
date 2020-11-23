---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Export to CSV

This document lists the different implementations of CSV export in GitLab codebase.

| Export type | How does it work | Advantages | Disadvantages | Existing examples |
|-------------|------------------|------------|---------------|---------------|
| Streaming | <ul><li>Start download straight-away</li><li>Query and write to stream in batches</li></ul> | <ul><li>Immediate availability of report</li><li>User can navigate away fromt the page</li></ul> | <ul><li>No progress indicator of what is left</li><li>Requires a reliable connection</li></ul> | [Audit Events export](../administration/audit_events.md#export-to-csv) |
| Downloading | <ul><li>Query and write data in batches into a temporary file</li><li>Load the file in memory</li><li>Send it back to the client</li></ul> | <ul><li>Immediate availability of report</li></ul> | <ul><li>Request time out</li><li>Performance issues while querying</li><li>Memory intensive</li><li>User has to stay on page</li></ul> | [Chain of Custody export](../user/compliance/compliance_dashboard.md#chain-of-custody-report) |
| As email attachment | <ul><li>Asynchronously process the query in the background.</li><li>Email user the export as an attachment</li></ul> | <ul><li>Asynchronous processing</li></ul>| <ul><li>Requires users to move to a different application (email) to download the CSV</li><li>Email providers may have attachment limit</li></ul> | [Export Issues to CSV](../user/project/issues/CSV_export.md) |
| As downloadable link in email | <ul><li>Asynchronously process the query in the background.</li><li>Email user an export link</li></ul> | <ul><li>Asynchronous processing</li><li>No dependency on email provider attachment limit</li></ul> | <ul><li>Requires users to move to a different application (email) to get access to the CSV</li></ul> | [Proposal for User permissions export](https://gitlab.com/gitlab-org/gitlab/-/issues/1772#note_417402799) |
| Polling (non-persistent state) | <ul><li>Asynchronously processes the query in the background</li><li>FE polls every few seconds to check if CSV file is ready</li></ul> | <ul><li>Asynchronous processing</li><li>Automatically downloads to local machine on completion</li><li>In-app solution</li></ul> | <ul><li>Non-persistable request - request expires when user navigates to a different page</li><li>API is processed for each polling request (can be enhanced)</li></ul> | [Export Vulnerabilities](../user/application_security/security_dashboard.md#export-vulnerabilities) |
| Polling (persistent state) | <ul><li>Asynchronously processes the query in the background.</li><li>BE maintains the export state</li><li>FE polls every few seconds to check status</li><li>FE shows 'Download link' when export is ready</li><li>User can download or regenerate a new report</li></ul> | <ul><li>Asynchronous processing</li><li>No database calls made during the polling requests (304 status is returned until export status changes)</li><li>Does not require user to stay in page until export is complete</li><li>In-app solution</li><li>Can be expanded into a generic CSV feature (such as dashboard / CSV API)</li></ul> | <ul><li> Does not automatically download the CSV export to local machine, requires users to click 'Download' button (can be enhanced)</li><ul> | [POC](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/43055/diffs) |
