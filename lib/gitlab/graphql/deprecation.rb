# frozen_string_literal: true

module Gitlab
  module Graphql
    class Deprecation
      REASONS = {
        renamed: 'This was renamed.',
        discouraged: 'Use of this is not recommended.'
      }.freeze

      include ActiveModel::Validations

      attr_reader :reason, :milestone, :replacement

      validates :milestone, presence: true, format: { with: /\A\d+\.\d+\z/, message: 'must be milestone-ish' }
      validates :reason, presence: true
      validates :reason,
                format: { with: /.*[^.]\z/, message: 'must not end with a period' },
                if: ->(d) { d.reason.is_a?(String) }
      validate :milestone_is_string
      validate :reason_known_or_string

      def self.parse(options)
        new(**options) if options
      end

      def initialize(reason: nil, milestone: nil, replacement: nil)
        @reason = reason.presence
        @milestone = milestone.presence
        @replacement = replacement.presence
      end

      def ==(other)
        other.is_a?(self.class) &&
          [reason_text, milestone, replacement] == [other.reason_text, other.milestone, other.replacement]
      end
      alias_method :eql, :==

      def milestone_is_string
        return if milestone.is_a?(String)

        errors.add(:milestone, 'must be a string')
      end

      def reason_known_or_string
        return if REASONS.key?(reason)
        return if reason.is_a?(String)

        errors.add(:reason, 'must be a known reason or a string')
      end

      def reason_text
        @reason_text ||= (REASONS[reason] || "#{reason.to_s.strip}.")
      end

      def deprecation_reason
        [
          reason_text,
          replacement && "Please use `#{replacement}`.",
          "#{deprecated_in}."
        ].compact.join(' ')
      end

      def description_suffix
        " #{deprecated_in}: #{reason_text}"
      end

      def deprecated_in(format: :plain)
        case format
        when :plain
          "Deprecated in #{milestone}"
        when :markdown
          "**Deprecated** in #{milestone}"
        end
      end

      def markdown(context: :inline)
        parts = [
          "#{deprecated_in(format: :markdown)}.",
          reason_text,
          replacement.then { |r| "Use: `#{r}`." if r }
        ].compact

        case context
        when :block
          ['WARNING:', *parts].join("\n")
        when :inline
          parts.join(' ')
        end
      end

      def edit_description(original_description)
        @original_description = original_description
        return unless original_description

        original_description + description_suffix
      end

      def original_description
        return unless @original_description
        return @original_description if @original_description.ends_with?('.')

        "#{@original_description}."
      end
    end
  end
end
