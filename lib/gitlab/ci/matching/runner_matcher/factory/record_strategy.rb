# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class RunnerMatcher
        class Factory
          class RecordStrategy
            def self.applies_to?(record)
              record.is_a?(::Ci::Runner)
            end

            def self.build_from(record)
              attributes = RunnerMatcher::ATTRIBUTES.to_h do |attribute|
                [attribute, record.public_send(attribute)] # rubocop:disable GitlabSecurity/PublicSend
              end

              [RunnerMatcher.new(attributes)]
            end
          end
        end
      end
    end
  end
end
