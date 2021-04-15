# frozen_string_literal: true

module Gitlab
  module Tracking
    class EventDefinition
      EVENT_SCHEMA_PATH = Rails.root.join('config', 'events', 'schema.json')
      BASE_REPO_PATH = 'https://gitlab.com/gitlab-org/gitlab/-/blob/master'

      attr_reader :path
      attr_reader :attributes

      def initialize(path, opts = {})
        @path = path
        @attributes = opts
      end

      def to_h
        attributes
      end

      def yaml_path
        "#{BASE_REPO_PATH}#{path.delete_prefix(Rails.root.to_s)}"
      end

      def validate!
        self.class.schemer.validate(attributes.stringify_keys).each do |error|
          error_message = <<~ERROR_MSG
            Error type: #{error['type']}
            Data: #{error['data']}
            Path: #{error['data_pointer']}
            Details: #{error['details']}
            Definition file: #{path}
          ERROR_MSG

          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(Gitlab::Tracking::Event::InvalidEventError.new(error_message))
        end
      end

      alias_method :to_dictionary, :to_h

      class << self
        def paths
          @paths ||= [Rails.root.join('config', 'events', '*.yml'), Rails.root.join('ee', 'config', 'events', '*.yml')]
        end

        def definitions
          @definitions ||= load_all!
        end

        def schemer
          @schemer ||= ::JSONSchemer.schema(Pathname.new(EVENT_SCHEMA_PATH))
        end

        def dump_metrics_yaml
          @metrics_yaml ||= definitions.values.map(&:to_h).map(&:deep_stringify_keys).to_yaml
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

          self.new(path, definition).tap(&:validate!)
        rescue => e
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(Gitlab::Tracking::Event::InvalidEventError.new(e.message))
        end

        def load_all_from_path!(definitions, glob_path)
          Dir.glob(glob_path).each do |path|
            definition = load_from_file(path)
            definitions[definition.path] = definition
          end
        end
      end

      private

      def method_missing(method, *args)
        attributes[method] || super
      end
    end
  end
end
