---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Pagination guidelines

This document gives a high-level overview about the current capabilities of GitLab to paginate over data.

## Why do we paginate?

Pagination is necessary to avoid loading too much data at the same time. This usually happens when we render lists. A very common scenario when we visualize want to visualize the parent - children relations (has many) on the UI.

Example: showing issues within a project.

As the number of issues grows within the project, the list gets longer. To render the list the backend does the following:

1. Load the records from the database, ideally in a particular order.
2. Serialize the records in Ruby.
3. Send the response.
4. The browser renders the content.

We have two options for rendering the content:

- HTML: backend deals with the rendering.
- JSON: the client (client side JavaScript) transforms the payload into HTML.

Rendering long lists can significantly affect both the frontend and backend performance.

- The database will need to read a lot's of data from the disk.
- The query result will eventually be transformed to Ruby objects which increases the number of memory allocations.
- Large responses will take more time to deliver to the client.
- Rendering long lists might freeze the end-user's browser.

## Options for pagination

### Offset based pagination

The most common way to paginate lists is using offset based pagination (UI and REST API). It's backed by the very popular `kaminari` ruby gem, which provides convinient helper methods to implement pagination on the backend.

Offset based pagination is leveraging the `LIMIT` + `OFFSET` SQL constructs to take out specific slices from the table.

Example database query when looking for the 2nd page of the issues within our project:

```sql
SELECT issues.* FROM issues WHERE project_id = 1 ORDER BY id LIMIT 20 OFFSET 20
```

1. Move an imaginary pointer over the rows and skip 20 of them.
2. Take out the next 20 rows.

Notice that the query also orders the rows by the primary key (`id`). When paginating data specifying the order is very important. Without it the returned rows are non-deterministic and can confuse the end-user.

### Page numbers

The kaminari gem renders a nice pagination bar on the UI with page numbers and optionally quick shortcuts the next, previous, first and last page buttons. To render these buttons kaminari needs to know the number of rows available, for that a count query is executed.

```sql
SELECT COUNT(*) FROM issues WHERE project_id = 1
```

### Performance

#### Index coverage

To achieve the best possible performance, the `ORDER BY` clause needs to be covered by an index.

Assuming that we have the following index:

```sql
CREATE INDEX index_on_issues_project_id ON issues (project_id);
```

Let's try to request the first page:

```sql
SELECT issues.* FROM issues WHERE project_id = 1 ORDER BY id LIMIT 20;
```

In ruby:

```ruby
Issue.where(project_id: 1).page(1).per(20)
```

The SQL query will return maximum 20 rows from the database which sounds quite efficient. However it doesn't mean that the database will only read 20 rows from the disk to produce the result.

This is what will happen:

1. The database will try to plan the execution the most efficient way possible.
2. The planner knows that we have an index covering the `project_id` column.
3. The database will read all issue rows using the index on `project_id`.
4. The rows are not sorted, so the database will need to sort the rows.
5. The database returns the first 20 rows.

In case the project has 10_000 rows, the database will read 10_000 rows and sort them in memory (or on disk). This is not going to scale well on the long term.

To fix this we need the following index:

```sql
CREATE INDEX index_on_issues_project_id ON issues (project_id, id);
```

By making the `id` column part of the index, the previous query will read maximum 20 rows. The query will perform the same way regardless of the number of issues.

NOTE:
Here we're leveraging the fact that database indexes are sorted so reading 20 rows will not require additional sotring.

#### Limitations

##### COUNT(*) on large dataset

Kaminari by default executes a count query to determine the number of pages for rendering the page links. Count queries can be quite expensive for large dataset and in an unfortunate case it will simply time out.

To work around this, we can run kaminari without count.

```ruby
Issue.where(project_id: 1).page(1).per(20).without_count
```

In this case the count query will not be executed and the pagination will no longer render the page numbers. We'll see only next and previous links.

##### OFFSET on large dataset

When we paginate over a large dataset we might notice that the response time will get slower and slower. This is due to the `OFFSET` clause that seeks through the rows and skips N rows.

From the user point of view this might not be visible, as the user paginates forward the previous rows might be still in the buffer cache of the database. If the user shares the link with someone else and it's opened after a few minutes or hours the response time might be significantly higher or it would even time out.

When requesting a large page number the database basically needs to read `PAGE * PAGE_SIZE` rows. This makes offset pagination **unsuitable for large data**.

### Tie-breaker column

When ordering the columns its advised to order on distinct columns only. Consider the following example:

|id|created_at|
|-|-|
|1|2021-01-04 14:13:43|
|2|2021-01-05 19:03:12|
|3|2021-01-05 19:03:12|

If we order by `created_at` the result would likely depend on how the records are located on the disk.

```sql
SELECT issues.* FROM issues ORDER BY created_at;
```

We can fix this by adding a second column to `ORDER BY`:

```sql
SELECT issues.* FROM issues ORDER BY created_at, id;
```

This change makes the `ORDER BY` clause distinct and we have "stable" sorting.

NOTE:
To make the query efficient we need index covering both columns: `(created_at, id)`
