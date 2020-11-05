---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GraphQL BatchLoader

GitLab uses the [batch-loader](https://github.com/exAspArk/batch-loader) ruby gem to optimize and avoid N+1 SQL queries.

## When should you use it?

We should try to batch load with GraphQL whenever we can. The flexibility of GraphQL allows developers to load data efficiently.

When implementing a new endpoint we should keep in mind to make the least number of SQL queries as possible.

## Implementation

To use batch loading, simply define the following ruby code in your resolver.

```ruby
def resolve(**args)
  BatchLoader::GraphQL.for(project.id).batch do |project_ids, loader|
    results = ::Ci::DailyBuildGroupReportResult
      .by_projects(project_ids)
      .with_coverage
      .with_default_branch
      .latest
      .summaries_per_project

    results.each do |project_id, summary|
      loader.call(project_id, summary)
    end
  end
end
```

- `project_id` is the id of the current project being queried
- `results` is the actual data set of the final SQL query
- `loader.call` is executed everytime a given field asks for the required data

Here an [example MR](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/46549) illustrating how to use our `BatchLoading` mechanism.

## Testing

Any GraphQL field that supports `BatchLoading` should be tested using the `batch_sync` method available in [GraphQLHelpers](https://gitlab.com/gitlab-org/gitlab/-/blob/master/spec/support/helpers/graphql_helpers.rb).

```ruby
it 'returns data as a batch' do
  results = batch_sync do
    resolve
  end

  expect(results).to eq(expected_results)
end

def resolve(args = {}, context = { current_user: current_user })
  resolve(described_class, obj: obj, args: args, ctx: context)
end
```

We must also use [QueryRecorder](../query_recorder.md) to make sure we are performing only **one SQL query** per call.

```ruby
it 'executes only 1 SQL query' do
  query_count = ActiveRecord::QueryRecorder.new { subject }.count

  expect(query_count).to eq(1)
end
```
