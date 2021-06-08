---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Database documentation

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/332716) in GitLab 14.0.

We aim to add documentation to GitLab's database model and internal details. Therefore, we introduce the concept
of "table ownership" below and showcase how to add meta-information like table descriptions.

## Table ownership

A database table is owned by one of [GitLab's stage groups](https://about.gitlab.com/handbook/product/categories/#hierarchy). We acknowledge the fact that many parts of the database are a shared resource and can be used and maintained by more than one group to power many of GitLab's features. However, it's important to have a single group being called out as a point of contact.

In this context, the responsibility of a group is to own a database table in the following sense:

1. Act as a point of contact for questions regarding the database modeling
1. Coordinate and communicate about changes if other groups and features are affected by a change
1. Responsible to act upon identified shortcomings and problems, in particular when associated with problems found in large scale environments (such as GitLab.com, for example)
1. Maintain database documentation for the table

Note that the group owning a particular table is **not** the only group able to make changes and otherwise use a database table. However, this group should be made aware of and review changes to the table.

## Table descriptions

The purpose of a table in a database model can often be described in a sentence or two. This information can be stored in the database along with the table in the form of a table comment.

## Adding to and changing database documentation

In order to manage database documentation, we store information about owners and database tables in YAML files under `db/docs/tables`. An example looks like this:

```yaml
---
tablename: schema_migrations
group: database
description: Contains information about executed database migrations
```

### Adding and changing database documentation

We currently only store documentation for tables and the following information:

1. `group:` - Table owner
1. `description:` - Table description (optional)

When adding a new table, missing YAML files can be generated using a rake task:

```
bundle exec rake gitlab:db:docs:generate_yaml
```

This will generate the a new YAML file under `db/docs/tables/$tablename.yaml`.

In a development environment, this happens automatically upon running `rake db:migrate`.

### Populating table comments

In PostgreSQL, tables can be annotated with comments. In order to populate table comments from the information contained in the YAML files, we can use this rake task:

```
bundle exec rake gitlab:db:docs:populate_table_comments
```

Note that in order to keep the table comments up to date, this executes automatically when loading the initial database schema and with subsequent database migrations.

Afterwards, available information is put as a table comment into the database and can be seen from client tools, for example with `psql`:

```sql
gitlabhq_development=# \dt+ schema_migrations
                                                          List of relations
 Schema |       Name        | Type  |  Owner  |  Size  |                                 Description
--------+-------------------+-------+---------+--------+-----------------------------------------------------------------------------
 public | schema_migrations | table | abrandl | 128 kB | Contains information about executed database migrations [owned by database group]
(1 row)
```
