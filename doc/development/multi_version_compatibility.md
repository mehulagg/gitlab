# Compatibility with multiple versions of the application running at the same time

When adding or changing features, we must be aware that there may be multiple versions of the application running
at the same time and connected to the same PostgreSQL and Redis databases. This could happen during a rolling deploy
when the servers are updated one by one.

During a rolling deploy, post-deployment DB migrations are run after all the servers have been updated. This means the
servers could be in these intermediate states:

1. Old application code running with new DB migrations already executed
1. New application code running with new DB migrations but without new post-deployment DB migrations

We must make sure that the application works properly in these states.

For GitLab.com, we also run a set of canary servers which run a more recent version of the application. Users with
the canary cookie set would be handled by these servers. Some URL patterns may also be forced to the canary servers,
even without the cookie being set. This also means that some pages may match the pattern and get handled by canary servers,
but AJAX requests to URLs (like the GraphQL endpoint) won't match the pattern.

With this canary setup, we'd be in this mixed-versions state for an extended period of time until canary is promoted to
production and post-deployment migrations run.

Also, there is a case that Sidekiq and Rails running in different versions becuase
deployments to each fleet are not guarannteed to be finished exactly the same moment.
This could cause an edge case that Rails changes a schema of data for a specific database column,
meanwhile Sidekiq tyring to parse the data as an old schema version.

## Examples of previous incidents

### Some links to issues and MRs were broken

When we moved MR routes, users on the new servers were redirected to the new URLs. When these users shared these new URLs in
Markdown (or anywhere else), they were broken links for users on the old servers.

For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/118840).

### Stale cache in issue or merge request descriptions and comments

We bumped the Markdown cache version and found a bug when a user edited a description or comment which was generated from a different Markdown
cache version. The cached HTML wasn't generated properly after saving. In most cases, this wouldn't have happened because users would have
viewed the Markdown before clicking **Edit** and that would mean the Markdown cache is refreshed. But because we run mixed versions, this is
more likely to happen. Another user on a different version could view the same page and refresh the cache to the other version behind the scenes.

For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/208255).

### Project service templates incorrectly copied

We changed the column which indicates whether a service is a template. When we create services, we copy attributes from the template
and set this column to `false`. The old servers were still updating the old column, but that was fine because we had a DB trigger
that updated the new column from the old one. For the new servers though, they were only updating the new column and that same trigger
was now working against us and setting it back to the wrong value.

For more information, see [the relevant issue](https://gitlab.com/gitlab-com/gl-infra/infrastructure/-/issues/9176).

### Sidebar wasn't loading for some users

We changed the data type of one GraphQL field. When a user opened an issue page from the new servers and the GraphQL AJAX request went
to the old servers, a type mismatch happened, which resulted in a JavaScript error that prevented the sidebar from loading.

For more information, see [the relevant issue](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/1772).

### CI artifact uploads were failing

We added a `NOT NULL` constraint to a column and marked it as a `NOT VALID` constraint so that it is not enforced on existing rows.
But even with that, this was still a problem because the old servers were still inserting new rows with null values.

For more information, see [the relevant issue](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/1944).

### Downtime on release features between canary and production deployment

We added a new column to an existing table with a `NOT NULL` constraint without specifying a default value,
that requires the application to set a value to the column always.

This seemed a reasonable implementation, however, the older version of the application
didn't set the value since the column didn't exist before.

The incident started occuring right after canary deployment finished. At that moment,
the database migration for adding a column to a table has successfully run and canary servers started using
the new version of code, hence QA was successful. Unfortunately, the production
servers still uses the older code, so it started failing to insert a new Release entry.

For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/64151).

### Downtime on a CI feature due to mixed versions running in Sidekiq and Rails

We changed a schema 

For more information, see [the relevant issue](https://gitlab.com/gitlab-org/gitlab/-/issues/230739).
