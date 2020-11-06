---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Constraint Naming Convention

The most common option is to let Rails pick the name for database constraints and indexes or let PostgreSQL use the defaults (when applicable). However, when needing to define custom names in Rails or working in Go applications where no ORM is used, it is important to follow strict naming conventions to improve consistency and discoverability.

The table below describes the convention that should be used to named custom PostgreSQL constraint.

| Type                     | Syntax                                                    | Notes                                                                                                                                                                        | Examples                                                                                                          |
|--------------------------|-----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| **Primary Key**          | `pkey_<table name>`                                       |                                                                                                                                                                              | `pkey_projects`                                                                                                   |
| **Foreign Key**          | `fkey_<table name>_<column(s) name>_<foreign table name>` |                                                                                                                                                                              | `fkey_projects_group_id_groups`                                                                                   |
| **Index**                | `idx_<table name>_on_<column(s) name>`                    |                                                                                                                                                                              | `idx_repositories_on_group_id`                                                                                    |
| **Unique Constraint**    | `key_<table name>_<column(s) name>`                       |                                                                                                                                                                              | `key_projects_group_id_and_name`                                                                                  |
| **Check Constraint**     | `check_<table name>_<column(s) name>_<optional suffix>`   | The optional suffix should  denote the type of validation, such as `length` and `enum`. It can also be used to desambiguate multiple `CHECK` constraints on the same column. | `check_projects_name_length`<br />`check_projects_type_enum`<br />`check_projects_admin1_id_and_admin2_id_differ` |
| **Exclusion Constraint** | `excl_<table name>_<column(s) name>_<suffix>`             | The suffix should denote the type of exclusion being performed.                                                                                                              | `excl_reservations_start_at_end_at_no_overlap`                                                                    |



## Observations

- The prefix used for each type of constraint matches the suffix used internally by PostgreSQL for that same type. Prefixes are preferred over suffices because they make it easier to identify the type of a given constraint quickly, as well as group them alphabetically;
- When targetting multiple columns with a constraint, their names should be joined with `_and_`.

