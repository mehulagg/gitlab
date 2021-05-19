# frozen_string_literal: true

ActsAsTaggableOn.strict_case_match = true

# tags_counter enables caching count of tags which results in an update whenever a tag is added or removed
# since the count is not used anywhere its better performance wise to disable this cache
ActsAsTaggableOn.tags_counter = false

# validate that counter cache is disabled
raise "Counter cache is not disabled" if
  ActsAsTaggableOn::Tagging.reflections["tag"].options[:counter_cache]

# TODO: CI Vertical: Make taggings/tags to live in CI database

# # Hack to use cross-table joins
# ::ActsAsTaggableOn::Tagging.table_name = 'gitlabhq_test_ee_primary.taggings'
# ::ActsAsTaggableOn::Tag.table_name = 'gitlabhq_test_ee_primary.tags'

# # Re-define
# ::ActsAsTaggableOn::Tagging = NonAbstractTagging
# ::ActsAsTaggableOn::Tag = AbstractTag
