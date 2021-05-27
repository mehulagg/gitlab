# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class BuildMatcher
        ATTRIBUTES = %i[
          protected
          tag_list
          build_ids
          project
        ].freeze

        attr_reader(*ATTRIBUTES)
        alias_method :protected?, :protected

        def initialize(params)
          ATTRIBUTES.each do |attribute|
            instance_variable_set("@#{attribute}", params.fetch(attribute))
          end
        end

        def has_tags?
          tag_list.present?
        end

        def not_matched_failure_reason
          :no_matching_runner
        end
      end
    end
  end
end

Gitlab::Ci::Matching::BuildMatcher.prepend_mod_with('Gitlab::Ci::Matching::BuildMatcher')
