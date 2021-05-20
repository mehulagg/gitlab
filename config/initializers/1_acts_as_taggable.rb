# frozen_string_literal: true

ActsAsTaggableOn.strict_case_match = true

# tags_counter enables caching count of tags which results in an update whenever a tag is added or removed
# since the count is not used anywhere its better performance wise to disable this cache
ActsAsTaggableOn.tags_counter = false

# validate that counter cache is disabled
raise "Counter cache is not disabled" if
  ActsAsTaggableOn::Tagging.reflections["tag"].options[:counter_cache]

# TODO: CI Vertical: Make taggings/tags to live in CI database
[::ActsAsTaggableOn::Tag, ::ActsAsTaggableOn::Tagging].each do |model|
  # We need to re-use connection specification, as each `connects_to` set-ups
  # a separate connection pool
  # model.abstract_class = true
  # model.connects_to database: { writing: :ci, reading: :ci }
  # model.abstract_class = false

  model.connection_specification_name = Ci::ApplicationRecord.connection_specification_name
end
