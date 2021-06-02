# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Seed
          module Build
            extend ::Gitlab::Utils::Override

            override :recalculate_yaml_variables!
            def recalculate_yaml_variables!
              additional_variables = dast_variables

              super

              seed_attributes[:yaml_variables].concat(additional_variables)
            end

            private

            attr_reader :pipeline, :seed_attributes

            def dast_variables
              name = seed_attributes[:yaml_variables].find {|var| var[:key] == "DAST_SCANNER_PROFILE"}[:value]

              result = AppSec::Dast::Variables::FetchService.new(
                container: @pipeline.project,
                params: { dast_scanner_profile_name: name }
              ).execute

              return [] unless result.success?

              result.payload.to_runner_variables
            end
          end
        end
      end
    end
  end
end
