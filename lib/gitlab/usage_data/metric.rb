# frozen_string_literal: true

module Gitlab
  class UsageData
    class Metric
      InvalidMetricError = Class.new(RuntimeError)

      PARAMS = %i[
        name
        full_path_generation_1
        description
        milestone
        introduced_by_url
        group
        time_frame
        distribution
        tier
        type
        data_source
      ].freeze

      class Definition
        attr_reader :path
        attr_reader :attributes

        PARAMS.each do |param|
          define_method(param) do
            attributes[param]
          end
        end

        def key
          full_path_generation_1
        end

        def initialize(path, opts = {})
          @path = path
          @attributes = {}

          PARAMS.each do |param|
            @attributes[param] = opts[param]
          end
        end

        class << self
          def paths
            @paths ||= [Rails.root.join('lib', 'gitlab', 'usage_data', 'metrics_definitions', '**', '*.yml')]
          end

          def definitions
            @definitions ||= load_all!
          end

          private

          def load_all!
            paths.each_with_object({}) do |glob_path, definitions|
              load_all_from_path!(definitions, glob_path)
            end
          end

          def load_from_file(path)
            definition = File.read(path)
            definition = YAML.safe_load(definition)
            definition.deep_symbolize_keys!

            self.new(path, definition)
          rescue => e
            raise Metric::InvalidMetricError, "Invalid definition for `#{path}`: #{e.message}"
          end

          def load_all_from_path!(definitions, glob_path)
            Dir.glob(glob_path).each do |path|
              definition = load_from_file(path)

              if previous = definitions[definition.path]
                raise Metric::InvalidMetricError, "Metric '#{definition.key}' is already defined in '#{previous.path}'"
              end

              definitions[definition.key] = definition
            end
          end
        end
      end
    end
  end
end
