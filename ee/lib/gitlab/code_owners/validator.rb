# frozen_string_literal: true

module Gitlab
  module CodeOwners
    class Validator
      def initialize(project, branch_name, paths)
        @project     = project
        @branch_name = branch_name
        @paths       = Array(paths)
      end

      def execute
        return unless @project.branch_requires_code_owner_approval?(@branch_name)
        return if loader.entries.blank?

        assemble_error_msg_for_codeowner_matches
      end

      private

      def assemble_error_msg_for_codeowner_matches
        "Pushes to protected branches that contain changes to files that\n" \
          "match patterns defined in `#{code_owner_path}` are disabled for\n" \
          "this project. Please submit these changes via a merge request.\n\n" \
          "The following pattern(s) from `#{code_owner_path}` were matched:\n" \
          "#{matched_rules.join('\n')}\n"
      end

      def matched_rules
        loader.entries.collect { |e| "- #{e.pattern}" }
      end

      def code_owner_path
        @project.repository.code_owners_blob(ref: @branch_name).path || "CODEOWNERS"
      end

      def loader
        @loader ||= ::Gitlab::CodeOwners::Loader.new(@project, @branch_name, @paths)
      end
    end
  end
end
