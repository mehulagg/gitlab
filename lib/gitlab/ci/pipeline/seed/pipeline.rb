# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Seed
        class Pipeline
          include Gitlab::Utils::StrongMemoize

          def initialize(pipeline, stages_attributes)
            @pipeline = pipeline
            @stages_attributes = stages_attributes
          end

          def errors
            stage_seeds.flat_map(&:errors).compact.presence
          end

          def stages
            stage_seeds.map(&:to_resource)
          end

          def size
            stage_seeds.sum(&:size)
          end

          private

          def stage_seeds
            strong_memoize(:stage_seeds) do
              seeds = @stages_attributes.inject([]) do |previous_stages, attributes|
                seed = Gitlab::Ci::Pipeline::Seed::Stage.new(@pipeline, attributes, previous_stages)
                previous_stages + [seed]
              end

              seeds.select(&:included?)
            end
          end
        end
      end
    end
  end
end
