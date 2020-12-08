# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Rules
        include ::Gitlab::Utils::StrongMemoize

        Result = Struct.new(:when, :start_in, :allow_failure) do
          def build_attributes
            attributes = {
              when: self.when,
              options: { start_in: start_in }.compact,
              allow_failure: allow_failure
            }.compact

            attributes[:options].merge!(override_exit_codes) if allow_failure_specified?
            attributes
          end

          def pass?
            self.when != 'never'
          end

          private

          def allow_failure_specified?
            return false unless allow_failure_enabled?

            !allow_failure.nil?
          end

          def override_exit_codes
            { allow_failure: { exit_codes: [] } }
          end

          def allow_failure_enabled?
            ::Gitlab::Ci::Features.allow_failure_with_exit_codes?
          end
        end

        def initialize(rule_hashes, default_when:)
          @rule_list    = Rule.fabricate_list(rule_hashes)
          @default_when = default_when
        end

        def evaluate(pipeline, context)
          if @rule_list.nil?
            Result.new(@default_when)
          elsif matched_rule = match_rule(pipeline, context)
            Result.new(
              matched_rule.attributes[:when] || @default_when,
              matched_rule.attributes[:start_in],
              matched_rule.attributes[:allow_failure]
            )
          else
            Result.new('never')
          end
        end

        private

        def match_rule(pipeline, context)
          @rule_list.find { |rule| rule.matches?(pipeline, context) }
        end
      end
    end
  end
end
