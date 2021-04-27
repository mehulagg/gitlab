---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Keyset pagination tutorial

This document demonstrates the usage of the keyset pagination library within the GitLab project. The library can be easily used in our HAML based views or in our REST API.

## API overview

Keyset pagination works without any configuration for simple ActiveRecord queries:

- Order by one column.
- Order by two columns, where the last column is the primary key.

The library can detect nullable and non-distinct columns and based on these, it will add extra ordering using the primary key. This is necessary because keyset pagination expects distinct order by values.

```ruby
Project.order(:created_at).keyset_paginate.records # ORDER BY created_at, id

Project.order(:name).keyset_paginate.records # ORDER BY name, id

Project.order(:created_at, id: desc).keyset_paginate.records # ORDER BY created_at, id

Project.order(created_at: :asc, id: :desc).keyset_paginate.records # ORDER BY created_at, id  DESC
```

The `keyset_paginate` method returns a special pagination object which contains the loaded records and additional information for requesting various pages.

```ruby
paginator = Project.order(:name).keyset_paginate

paginator.to_a # same as records

cursor = paginator.cursor_for_next_page # encoded column attributes for the next page

paginator = Project.order(:name).keyset_paginate(cursor: cursor).records # loading the next page
```

Since keyset pagination does not support page numbers, we are restricted to go to the following pages:

- Next page
- Previous page
- Last page
- First page

## Usage in Rails views

Consider the following controller action, we simply list the projects ordered by name:

```ruby
def index
  @projects = Project.order(:name).keyset_paginate(cursor: params[:cursor])
end
```

In the view, we can render the records:

```ruby
- if @projects.any?
  - @projects.each do |project|
    .project-container
      = project.name

  = keyset_paginate @projects
```

## Complex order configuration

Common `ORDER BY` configurations will be handled by the `keyset_paginate` method automatically so no manual configuration is needed. There are a few edge cases where order object configuration is necessary:

- `NULLS LAST` ordering
- Function based ordering
- Ordering with a custom tie breaker column, like `iid`.

These order objects can be defined in the model classes as normal ActiveRecord scopes, there is no distinct behavior that blocks using these scopes elsewhere (kaminari, background jobs).

### Relative position ordering

Consider the following scope:

```ruby

scope = Issue.where(project_id: 10).order(Gitlab::Database.nulls_last_order('relative_position', 'DESC'))
# SELECT "issues".* FROM "issues" WHERE "issues"."project_id" = 10 ORDER BY relative_position DESC NULLS LAST

scope.keyset_paginate # raises: Gitlab::Pagination::Keyset::Paginator::UnsupportedScopeOrder: The order on the scope does not support keyset pagination
```

The `keyset_paginate` method raises error because the order value on the query is a custom SQL string and not standard Rails. We cannot automatically infer configuration values from it.

To make keyset pagination work, we need to configure a custom order objects, to do so, we need to collect information about the order column.

- `relative_position` can have duplicated values, there is no index that prevents duplicates.
- `relative_position` can have null values because we don't have not null constraint on the column.
  - For this, we need to determine where will we see NULL values, at the begining of the resultset or at the end. (`NULLS LAST`)
- Keyset pagination requires distinct order columns, so we'll need to add the primary key (`id`) to make the order distinct.
- Jumping to the last page and paginating backwards actually reverses the `ORDER BY` clause. For this, we'll need to provide the reversed `ORDER BY` clause.

```ruby
order = Gitlab::Pagination::Keyset::Order.build([
  # The attributes are documented in the `lib/gitlab/pagination/keyset/column_order_definition.rb` file
  Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
    attribute_name: 'relative_position',
    column_expression: Issue.arel_table[:relative_position],
    order_expression: Gitlab::Database.nulls_last_order('relative_position', 'DESC'),
    reversed_order_expression: Gitlab::Database.nulls_first_order('relative_position', 'ASC'),
    nullable: :nulls_last,
    order_direction: :desc,
    distinct: false
  ),
  Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
    attribute_name: 'id',
    order_expression: Issue.arel_table[:id].asc,
    nullable: :not_nullable,
    distinct: true
  )
])

scope = Issue.where(project_id: 10).order(order) # or reorder()

scope.keyset_paginate.records # works
```

### Function based ordering

In this example we look at a very simple ordering, we'll simply multiply the `id` by 10. Since the `id` column is unique, we need to define only one column.

```ruby
order = Gitlab::Pagination::Keyset::Order.build([
  Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
    attribute_name: 'id_times_ten',
    order_expression: Arel.sql('id * 10').asc,
    nullable: :not_nullable,
    order_direction: :asc,
    distinct: true,
    add_to_projections: true
  )
])

paginator = Issue.where(project_id: 10).order(order).keyset_paginate(per_page: 5)
puts paginator.records.map(&:id_times_ten)

cursor = paginator.cursor_for_next_page

paginator = Issue.where(project_id: 10).order(order).keyset_paginate(cursor: cursor, per_page: 5)
puts paginator.records.map(&:id_times_ten)
```

The `add_to_projections` flag tells the paginator to expose the column expression in the `SELECT` clause. This is necessary because the keyset pagination needs to somehow extract last value from the records in order to request the next page.

### `iid` based ordering

When ordering issues, the database ensures that we'll have distinct `iid` values within a project. Ordering by one column is enough to make the pagination work if we have `project_id` filter present.

```ruby
order = Gitlab::Pagination::Keyset::Order.build([
  Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
    attribute_name: 'iid',
    order_expression: Issue.arel_table[:iid].asc,
    nullable: :not_nullable,
    distinct: true
  )
])

scope = Issue.where(project_id: 10).order(order)

scope.keyset_paginate.records # works
```
