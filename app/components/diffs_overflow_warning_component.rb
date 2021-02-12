# frozen_string_literal: true

class DiffsOverflowWarningComponent < BaseComponent
  attr_reader :project, :context, :diffs

  def initialize(project:, context:, diffs:)
    @project = project
    @context = context
    @diffs = diffs
  end

  def render_overflow_warning?
    if diffs.raw_diff_files.any?(&:too_large?)
      Gitlab::Metrics.add_event(:diffs_overflow_single_file_limits)
    end

    diffs.raw_diff_files.overflow?.tap do |overflown|
      Gitlab::Metrics.add_event(:diffs_overflow_collection_limits) if overflown
    end
  end
end
