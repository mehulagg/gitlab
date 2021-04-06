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

        ::AlertManagement::AlertPayloadField.new(
          project: project,
          path: path,
          label: label_for(path),
          type: type
        )
      end

      # Code duplication with Gitlab::InlineHash#merge_keys ahead!
      # See https://gitlab.com/gitlab-org/gitlab/-/issues/299856
      #
      # Determines the keys and indicies needed to identify a value.
      # in a hash with nested values.
      #
      # Example)
      # {
      #   apple: [:a, :b, :c],
      #   pickle: {
      #     dill: 1,
      #     kosher: 2,
      #     sweet: 3,
      #     garlic: 4
      #   },
      #   pear: [{ bosc: 5, bartlett: 6 }],
      #   peach: [{ some: { none: 14, maybe: { not: 4 } } }, 'PLEASE', { plum: 4, apricot: ['red', 'purple'] }]
      # }
      #
      # Becomes:
      # [[[:apple], [:a, :b, :c]],
      # [[:apple, 0], :a],
      # [[:apple, 1], :b],
      # [[:apple, 2], :c],
      # [[:pickle, :garlic], 4],
      # [[:pickle, :sweet], 3],
      # [[:pickle, :kosher], 2],
      # [[:pickle, :dill], 1],
      # [[:pear], [{:bosc=>5, :bartlett=>6}]],
      # [[:pear, 0, :bartlett], 6],
      # [[:pear, 0, :bosc], 5],
      # [[:peach], [{:some=>{:none=>14, :maybe=>{:not=>4}}}, "PLEASE", {:plum=>4, :apricot=>["red", "purple"]}]],
      # [[:peach, 1], "PLEASE"],
      # [[:peach, 2, :apricot], ["red", "purple"]],
      # [[:peach, 2, :apricot, 0], "red"],
      # [[:peach, 2, :apricot, 1], "purple"],
      # [[:peach, 2, :plum], 4],
      # [[:peach, 0, :some, :maybe, :not], 4],
      # [[:peach, 0, :some, :none], 14]]
      #
      # @return Enumerator
      def deep_traverse(hash)
        return to_enum(__method__, hash) unless block_given?

        pairs = hash.map { |k, v| [[k], v] }

        until pairs.empty?
          key, value = pairs.shift

          if value.is_a?(Hash)
            value.each { |k, v| pairs.unshift [key + [k], v] }
          elsif value.is_a?(Array)
            yield key, value

            value.each.with_index do |sub_value, index|
              if sub_value.is_a?(Hash)
                sub_value.each { |k, v| pairs.unshift [key + [index, k], v] }
              else
                yield (key + [index]), sub_value
              end
            end
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

      def label_for(path)
        return path.last.humanize unless path.last.is_a?(Integer)

        # Integers represent array indicies
       "#{path.second_to_last}[#{path.last}]"
      end
    end
  end
end
