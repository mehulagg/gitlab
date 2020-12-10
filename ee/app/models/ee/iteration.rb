# frozen_string_literal: true

module EE
  module Iteration
    extend ActiveSupport::Concern

    prepended do
      include Timebox

      has_many :issues, foreign_key: 'sprint_id'
      has_many :merge_requests, foreign_key: 'sprint_id'
    end

    class_methods do
      def reference_pattern
        # NOTE: The id pattern only matches when all characters on the expression
        # are digits, so it will match *iteration:2 but not *iteration:2.1 because that's probably a
        # iteration name and we want it to be matched as such.
        @reference_pattern ||= %r{
        (#{::Project.reference_pattern})?
        #{::Regexp.escape(reference_prefix)}
        (?:
          (?<iteration_id>
            \d+(?!\S\w)\b # Integer-based iteration id, or
          ) |
          (?<iteration_name>
            [^"\s]+\b |  # String-based single-word iteration title, or
            "[^"]+"      # String-based multi-word iteration surrounded in quotes
          )
        )
      }x.freeze
      end

      def link_reference_pattern
        @link_reference_pattern ||= super("iterations", /(?<iteration>\d+)/)
      end
    end

    # Show just the title when we manage to find an iteration, without the reference pattern,
    # since it's long and unsightly.
    def reference_link_text(from = nil)
      self.title
    end

    def supports_timebox_charts?
      resource_parent&.feature_available?(:iterations) && weight_available?
    end

    private

    def timebox_format_reference(format = :id)
      raise ::ArgumentError, _('Unknown format') unless [:id, :name].include?(format)

      if format == :name
        super
      else
        id
      end
    end
  end
end
