# frozen_string_literal: true

module Gitlab
  module AlertManagement
    class AlertPayloadFieldExtractor
      def initialize(project)
        @project = project
      end

      def extract(payload)
        deep_traverse(payload.deep_stringify_keys)
          .map { |path, value| field(path, value) }
          .compact
      end

      private

      attr_reader :project

      def field(path, value)
        type = type_of(value)
        return unless type

        label = path.last.humanize

        ::AlertManagement::AlertPayloadField.new(
          project: project,
          path: path,
          label: label,
          type: type
        )
      end

      # Code duplication with Gitlab::InlineHash#merge_keys ahead!
      # See https://gitlab.com/gitlab-org/gitlab/-/issues/299856
      def deep_traverse(hash)
        return to_enum(__method__, hash) unless block_given?

        pairs = hash.map { |k, v| [[k], v] }

        until pairs.empty?
          key, value = pairs.shift

          if value.is_a?(Hash)
            value.each { |k, v| pairs.unshift [key + [k], v] }
          else
            yield key, value
          end
        end
      end

      def type_of(value)
        case value
        when Array
          ::AlertManagement::AlertPayloadField::ARRAY_TYPE
        when /^\d{4}/ # assume it's a datetime
          ::AlertManagement::AlertPayloadField::DATETIME_TYPE
        when String
          ::AlertManagement::AlertPayloadField::STRING_TYPE
        end
      end
    end
  end
end
