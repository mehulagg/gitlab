# frozen_string_literal: true

module Overcommit::Hook::CommitMsg
  class EnsureCommitBodyIsPresent < Base
    def run
      min_changed_files = config['min_changed_files'] || 3
      min_changed_lines = config['min_changed_lines'] || 30

      return :pass if modified_files.count < min_changed_files

      if calculate_changed_lines >= min_changed_lines
        case commit_body_length
        when 0
          [:fail, "Commit body must be present when changing more than #{min_changed_lines} lines across more than #{min_changed_files} files"]
        else
          :pass
        end
      end
    end

    private

    def calculate_changed_lines
      count = 0

      modified_files.each do |file|
        count += modified_lines_in_file(file).count
      end

      count
    end

    def commit_body_length
      return 0 unless commit_message_lines.count > 2

      commit_message_lines[2..-1]
        .map(&:chomp)
        .map(&:length)
        .sum # rubocop:disable CodeReuse/ActiveRecord
    end
  end
end
