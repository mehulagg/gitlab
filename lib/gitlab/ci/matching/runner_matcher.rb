# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class RunnerMatcher
        ATTRIBUTES = %i[
          runner_type
          public_projects_minutes_cost_factor
          private_projects_minutes_cost_factor
          run_untagged
          access_level
          tag_list
        ].freeze

        attr_reader(*ATTRIBUTES)

        def self.for(record)
          Factory.new(record).create
        end

        def initialize(params)
          ATTRIBUTES.each do |attribute|
            instance_variable_set("@#{attribute}", params.fetch(attribute))
          end
        end

        def matches?(build)
          return false if ref_protected? && !build.protected?

          accepting_tags?(build)
        end

        def instance_type?
          runner_type.to_sym == :instance_type
        end

        private

        def ref_protected?
          access_level.to_sym == :ref_protected
        end

        def accepting_tags?(build)
          (run_untagged || build.has_tags?) && (build.tag_list - tag_list).empty?
        end
      end
    end
  end
end

Gitlab::Ci::Matching::RunnerMatcher.prepend_if_ee('EE::Gitlab::Ci::Matching::RunnerMatcher')
