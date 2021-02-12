# frozen_string_literal: true

class DiffsStatsComponent < BaseComponent
  attr_reader :diff_files

  def initialize(diff_files:)
    @diff_files = diff_files
  end

  def sum_added_lines
    @sum_added_lines ||= diff_files.sum(&:added_lines)
  end

  def sum_removed_lines
    @sum_removed_lines ||= diff_files.sum(&:removed_lines)
  end
end
