# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class BuildMatcher
        class Factory
          class PipelineStrategy
            class << self
              def applies_to?(record)
                record.is_a?(::Ci::Pipeline)
              end

              def build_from(pipeline)
                new(pipeline).execute
              end

              def pluckable_attributes
                @pluckable_attributes ||= [
                  :id,
                  Arel.sql("(#{tag_list_sql})")
                ].freeze
              end

              private

              # rubocop: disable CodeReuse/ActiveRecord
              def tag_list_sql
                ActsAsTaggableOn::Tagging
                  .joins(:tag)
                  .select('COALESCE(array_agg(tags.name ORDER BY name), ARRAY[]::text[])')
                  .where(taggable_type: 'CommitStatus')
                  .where('taggings.taggable_id=ci_builds.id')
                  .to_sql
              end
              # rubocop: enable CodeReuse/ActiveRecord
            end

            def initialize(pipeline)
              @pipeline = pipeline
            end

            # rubocop: disable CodeReuse/ActiveRecord
            def execute
              values_by_tags.map do |tags, attributes|
                BuildMatcher.new({
                  build_ids: attributes.pluck(0),
                  tag_list:  tags,
                  project:   pipeline.project,
                  protected: pipeline.protected?
                })
              end
            end
            # rubocop: enable CodeReuse/ActiveRecord

            private

            attr_reader :pipeline
            delegate :pluckable_attributes, to: :class

            def values_by_tags
              raw_values.group_by { |value| value[1] }
            end

            # rubocop: disable CodeReuse/ActiveRecord
            def raw_values
              pipeline
                .builds
                .pluck(*pluckable_attributes)
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end
    end
  end
end
