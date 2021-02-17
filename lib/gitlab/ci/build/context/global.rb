# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Context
        class Global < Base
          include Gitlab::Utils::StrongMemoize

          def initialize(pipeline, yaml_variables:)
            super(pipeline)

            @yaml_variables = yaml_variables.to_a
          end

          def variables
            strong_memoize(:variables) do
              # This is a temporary piece of technical debt to allow us access
              # to the CI variables to evaluate workflow:rules
              # with the result. We should refactor away the extra Build.new,
              # but be able to get CI Variables directly from the Seed::Build.
              variables_collection.to_hash
            end
          end

          def variables_collection
            strong_memoize(:variables_collection) do
              vars = stub_build.scoped_variables.reject { |var| var[:key] =~ /\ACI_(JOB|BUILD)/ }
              Gitlab::Ci::Variables::Collection.new(vars)
            end
          end

          private

          def stub_build
            ::Ci::Build.new(build_attributes)
          end

          def build_attributes
            pipeline_attributes.merge(
              yaml_variables: @yaml_variables)
          end
        end
      end
    end
  end
end
