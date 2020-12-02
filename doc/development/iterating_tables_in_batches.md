---
stage: Enablement
group: Database
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Iterating Tables In Batches

Rails provides a method called `in_batches` that can be used to iterate over
rows in batches. For example:

```ruby
User.in_batches(of: 10) do |relation|
  relation.update_all(updated_at: Time.now)
end
```

Unfortunately this method is implemented in a way that is not very efficient,
both query and memory usage wise.

To work around this you can include the `EachBatch` module into your models,
then use the `each_batch` class method. For example:

```ruby
class User < ActiveRecord::Base
  include EachBatch
end

User.each_batch(of: 10) do |relation|
  relation.update_all(updated_at: Time.now)
end
```

This will end up producing queries such as:

```plaintext
User Load (0.7ms)  SELECT  "users"."id" FROM "users" WHERE ("users"."id" >= 41654)  ORDER BY "users"."id" ASC LIMIT 1 OFFSET 1000
  (0.7ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."id" >= 41654) AND ("users"."id" < 42687)
```

The API of this method is similar to `in_batches`, though it doesn't support
all of the arguments that `in_batches` supports. You should always use
`each_batch` _unless_ you have a specific need for `in_batches`.

## Avoid iterating over non-unique columns
One should proceed with extra caution, and possibly avoid iterating over a column that can contain duplicate values.
When you iterate over an attribute that is not unique, even with the applied max batch size, there is no guarantee that the resulting batches will not surpass it.
The following snippet demonstrates this situation:

```sql
gitlabhq_production=> SELECT COUNT(*) FROM ci_builds where user_id BETWEEN 1 AND 10000;
 count
--------
 970104
(1 row)

gitlabhq_production=> SELECT COUNT(*) FROM ci_builds where user_id BETWEEN 10000 AND 20000;
 count
--------
 570848
(1 row)

gitlabhq_production=> SELECT COUNT(*) FROM ci_builds where user_id BETWEEN 20000 AND 30000;
 count
--------
 217037
(1 row)
```

In the previous example, even though the batch size is equal to 10,000 because it's applied to an attribute that is not unique within the given relation (`user_id`),
the resulting batches vastly exceed the expected batch size, something that can cause the batch approach to fail due to statement timeouts. That happens because when taking `n` possible values of attributes, 
one can't tell for sure that the number of records that contains them will be less than `n`.
