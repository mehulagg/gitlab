# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Quota
          class Deployments < Ci::Limit
            include ::Gitlab::Utils::StrongMemoize
            include ActionView::Helpers::TextHelper

            def initialize(namespace, pipeline, command)
              @namespace = namespace
              @pipeline = pipeline
              @command = command
            end

            def enabled?
              limit > 0
            end

            def exceeded?
              return false unless enabled?

              excessive_seeds_count > 0
            end

            def message
              return unless exceeded?

              "Pipeline deployment limit exceeded by #{pluralize(excessive_seeds_count, 'deployment')}!"
            end

            private

            def excessive_seeds_count
              pipeline_deployment_count - limit
            end

            def pipeline_deployment_count
              strong_memoize(:pipeline_deployment_count) do
                @command.stage_seeds.sum do |stage_seed|
                  stage_seed.seeds.count do |build_seed|
                    build_seed.attributes[:environment].present?
                  end
                end
              end
            end

            def limit
              strong_memoize(:limit) do
                @namespace.actual_limits.ci_pipeline_deployments
              end
            end
          end
        end
      end
    end
  end
end
