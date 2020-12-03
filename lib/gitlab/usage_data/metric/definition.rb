# frozen_string_literal: true

module Gitlab
  class UsageData
    class Metric
      class Definition
        include ::Gitlab::UsageData::Metric::Shared

        attr_reader :path
        attr_reader :attributes

        PARAMS.each do |param|
          define_method(param) do
            attributes[param]
          end
        end

        # The key is defined by default_generation and full_path
        def key
          full_path[default_generation.to_sym]
        end

        def initialize(path, opts = {})
          @path = path
          @attributes = {}

          PARAMS.each do |param|
            @attributes[param] = opts[param]
          end
        end

        def to_h
          attributes
        end

        alias_method :to_dictionary, :to_h

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
