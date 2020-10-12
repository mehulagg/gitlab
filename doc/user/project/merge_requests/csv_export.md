# Export Merge Requests to CSV **(CORE)**

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/3619) in GitLab Core 13.5.

Merge requests can be exported as CSV from GitLab and are sent to your primary email as an attachment.

## Overview

Export Merge Requests CSV enables you and your team to export all the data collected from merge requests into a comma-separated values (CSV) file, which stores tabular data in plain text. 

To export Merge Requests to CSV, navigate to your **Merge Requests list** from the sidebar of a project and click **Export to CSV**.

Exported files are generated asynchronously and delivered as an email attachment upon generation.

## Output

| Column             | Description                                                  |
|--------------------|--------------------------------------------------------------|
| MR ID              | MR iid                                                       |
| URL                | A link to the merge request on GitLab                        |
| Title              | Merge request title                                          |
| State              | Opened, Closed, Locked, or Merged                            |
| Description        | Merge request description                                    |
| Source Branch      | Source branch                                                |
| Target Branch      | Target branch                                                |
| Source Project ID  | ID of the source project                                     |
| Target Project ID  | ID of the target project                                     |
| Author             | Full name of the merge request author                        |
| Author Username    | Username of the author, with the @ symbol omitted            |
| Assignees          | Full names of the merge request assignees, joined with a `,` |
| Assignee Usernames | Username of the assignees, with the @ symbol omitted         |
| Approvers          | Full names of the approvers, joined with a `,`               |
| Approver Usernames | Username of the approvers, with the @ symbol omitted         |
| Merged User        | Full name of the merged user                                 |
| Merged Username    | Username of the merge user, with the @ symbol omitted        |
| Milestone ID       | ID of the merge request milestone                            |
| Created At (UTC)   | Formatted as YYYY-MM-DD HH:MM:SS                             |
| Updated At (UTC)   | Formatted as YYYY-MM-DD HH:MM:SS                             |

## Limitations

- Export merge requests to CSV is not available at the Group’s merge request list.
- As the merge request CSV file is sent as an email attachment, the size is limited to 15MB to ensure successful delivery across a range of email providers. If you need to minimize the size of the file, you can narrow the search before export. For example, you can set up exports of open and closed merge requests in separate files. 
