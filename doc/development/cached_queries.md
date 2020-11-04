# Cached Queries

Rails provides an [SQL query cache](https://guides.rubyonrails.org/caching_with_rails.html#sql-caching), 
used to cache the results of database queries for the duration of the request. 
If Rails encounters the same query again for that request,
it will use the cached result set as opposed to running the query against the database again.
The query results are only cached for the duration of that single request, it does not persist across multiple requests.

## Why cached queries are considered bad

The cached queries help with reducing DB load, but they still:

- Consume memory.
- Require as to re-instantiate each `ActiveRecord` object.
- Require as to re-instantiate each relation of the object.
- Make us spend additional CPU-cycles to look into a list of cached queries.

They are cheaper, but they are not cheap at all from `memory` perspective.
 
Cached SQL queries, could mask [N+1 query problem](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations).
If those N queries are executing the same query, it will not hit the database N times, it will return the cached results instead,
which is still expensive since we need to re-initialize objects each time, and this is CPU/Memory expensive.
Instead, you should use the same in-memory objects, if possible. 

## How to detect

### Detect potentially affected end-points using Kibana

### Inspect suspicious end-point using Performance Bar

When building features, you could use [Performance bar](../administration/monitoring/performance/performance_bar.md)
in order to list Database queries, which will include cached queries as well. 

## What to look for

If you see a lot of similar queries,
this often indicates an N+1 query issue (or a similar kind of query batching problem).
If you see same cached query executed multiple times, this often indicates a masked N+1 query problem.

## How to measure impact of change
