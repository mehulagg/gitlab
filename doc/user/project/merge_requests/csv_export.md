# Export Merge Requests to CSV

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/3619) in GitLab Core 13.5.

Merge requests can be exported as CSV from GitLab and are sent to your primary email as an attachment.

## Overview

Export Merge Requests CSV enables you and your team to export all the data collected from merge requests into a comma-separated values (CSV) file, which stores tabular data in plain text. 

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
- As the merge requests will be sent as an email attachment, there is a limit on how much data can be exported. Currently this limit is 15MB to ensure successful delivery across a range of email providers. If this limit is reached we suggest narrowing the search before export, perhaps by exporting open and closed merge requests separately. 
