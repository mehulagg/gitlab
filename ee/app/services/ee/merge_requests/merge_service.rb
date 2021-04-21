# frozen_string_literal: true

module EE
  module MergeRequests
    module MergeService
      private

      def validate!
        super

        error = 'Waiting for code owner approvals to refresh' unless code_owner_rules_synced?

        raise_error(error) if error
      end

      def code_owner_rules_synced?
        existing_rules = merge_request.approval_rules.matching_pattern(patterns).to_a

        code_owner_entries.all? do |entry|
          existing_rules.detect { |rule| rule.name == entry.pattern }
        end
      end

      def patterns
        @patterns ||= code_owner_entries.map(&:pattern)
      end

      def code_owner_entries
        @code_owner_entries ||= ::Gitlab::CodeOwners
          .entries_for_merge_request(merge_request)
      end
    end
  end
end
