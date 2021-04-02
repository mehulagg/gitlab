---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Rename table without downtime

With our database helper methods built into the GitLab application it's possible to rename a database table without downtime.

The technique builds on top of database views, using the following steps:

1. Rename the database table.
2. Create a database view using the old database table name by pointing to the new database table.

Example: `issues` table is renamed to `tickets`

```sql
BEGIN;
  ALTER TABLE issues RENAME TO tickets;
  CREATE VIEW issues AS SELECT * FROM tickets;
COMMIT;
```

The database view makes possible for the old version of the application to use the old database
table name. There is additional work needed on the application level because database views are
not exposing the underlying table schema (default values, not null constraints and indexes).
ActiveRecord heavily relies on this data, for example: initializing new models.

To work around this limitation, we need to tell ActiveRecord, how to acquire this information.

## Milestone 1: Mark the ActiveRecord model

In this milestone we extend the model to optionally fetch the database table information
(for the SchemaCache) from the new database table.

```ruby
class Issue < ActiveRecord::Base
  include RenameTable

  table_will_be_renamed from: 'issues', to: 'tickets'
end
```

Note: In this milestone the `tickets` database table will not exist yet.

## Milestone 2: Rename the database table

The migration needs to be executed as a standard migration (not a post migration).

```ruby
  include Gitlab::Database::MigrationHelpers

  def up
    rename_table_safely(:issues, :tickets)
  end

  def down
    undo_rename_table_safely(:issues, :tickets)
  end
```

Note: The model code also needs to be modified to point to the new database table. This can be done by
renaming the model or setting the `self.table_name` variable.

As a post migration, we need to remove the database view. At this point we don't have appliations
using the old database table name in the queries.

```ruby
  include Gitlab::Database::MigrationHelpers

  def up
    finalize_table_rename(:issues, :tickets)
  end

  def down
    undo_finalize_table_rename(:issues, :tickets)
  end
```

### Zero downtime deployments

When the application is upgraded without downtime, there can be application instances
running the old code. The old code still references the old database table. The queries
will function without any problems, because the backward compatible database view is
in place.

In case the old version of the application needs to be restarted or reconnect to the
database, ActiveRecord will fetch the column information again. At this time, our previously
marked model (`table_will_be_renamed`) will instruct ActiveRecord to use the new database table name
when fetching the database table information.

The new version of the application will automatically start using the new database table.

### Milestone 3: Remove the mark from the ActiveRecord model

In this milestone we clean up the `table_will_be_renamed` method call and remove the `include`.
