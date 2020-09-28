# frozen_string_literal: true

module Overcommit::Hook::CommitMsg
  class EnsureCommitBodyIsPresent < Base
    def run
      max_changed_lines_in_commit = config['min_changed_files'] || 3
      max_changed_files_in_commit = config['min_changed_lines'] || 30
      failure_message = "Commits that change #{max_changed_lines_in_commit} or more lines across " \
        "at least #{max_changed_files_in_commit} files must describe these changes in the commit body".freeze

      return :pass if modified_files.count < max_changed_files_in_commit

      if calculate_changed_lines >= max_changed_lines_in_commit
        case commit_body_length
        when 0
          [:fail, failure_message]
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
