# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class RunnerMatcher
        class Factory
          class RelationStrategy
            class << self
              def applies_to?(relation)
                relation.is_a?(ActiveRecord::Relation) &&
                  relation.klass == ::Ci::Runner
              end

              # rubocop: disable CodeReuse/ActiveRecord
              def build_from(relation)
                params = RunnerMatcher::ATTRIBUTES.map do |attribute|
                  pluckable_attributes_map.fetch(attribute, attribute)
                end

                # we use distinct to de-duplicate data
                relation.distinct.pluck(*params).map do |values|
                  attributes = RunnerMatcher::ATTRIBUTES.zip(values).to_h
                  RunnerMatcher.new(attributes)
                end
              end
              # rubocop: enable CodeReuse/ActiveRecord

              private

              def pluckable_attributes_map
                @pluckable_attributes_map ||= {
                  tag_list: Arel.sql("(#{tag_list_sql})")
                }.freeze
              end

              # rubocop: disable CodeReuse/ActiveRecord
              def tag_list_sql
                ActsAsTaggableOn::Tagging
                  .joins(:tag)
                  .select('COALESCE(array_agg(tags.name ORDER BY name), ARRAY[]::text[])')
                  .where(taggable_type: 'Ci::Runner')
                  .where('taggings.taggable_id=ci_runners.id')
                  .to_sql
              end
              # rubocop: enable CodeReuse/ActiveRecord
            end
          end
        end
      end
    end
  end
end
