---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Maintenance operations

This page details various database related operations that may relate to development.

## Disabling an index

There are certain situations in which you might want to disable an index before removing it:

- The index is on a large table and rebuilding it in the case of a revert would take a long time.
- It is uncertain whether or not the index is being used in ways that are not fully visible.

To disable an index before removing it:

1. Inform the database team in the issue `@gitlab-org/database-team` or in Slack `#g_database`.
1. Open a [production infrastructure issue](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/new)
and use the "Production Change" template.
1. Add a step to verify the index is used; this would likely be an `EXPLAIN` command for a query known to use the index.
1. Add the step to disable the index:

   ```sql
   UPDATE pg_index SET indisvalid = false WHERE indexrelid = 'index_issues_on_foo'::regclass;
   ```

1. Add a step to verify that the index is invalid and not included anymore in the query plan of the reference query.
1. Verify the index is invalid on replicas:

   ```sql
   SELECT indisvalid FROM pg_index WHERE indexrelid = 'index_issues_on_foo'::regclass;
   ```

1. Add steps for rolling back the invalidation:
   1. Rollback the index invalidation

      ```sql
      UPDATE pg_index SET indisvalid = true WHERE indexrelid = 'index_issues_on_foo'::regclass;
      ```

   1. Verify the index is being used again.

See this [example infrastructure issue](https://gitlab.com/gitlab-com/gl-infra/production/-/issues/2795) for reference.
