# frozen_string_literal: true

# rubocop: disable Gitlab/ModuleWithInstanceVariables

module EE
  module Gitlab
    module BackgroundMigration
      # This background migration creates any approver rule records according
      # to the given project IDs range. A _single_ INSERT is issued for the given range.
      module PopulateAnyApprovalRuleForProjects
        extend ::Gitlab::Utils::Override

        MAX_VALUE = 2**15 - 1

        override :perform
        def perform(from_id, to_id)
          select_sql =
            ::Project
              .where(project_approval_rules_not_exists_clause)
              .where(id: from_id..to_id)
              .where('approvals_before_merge <> 0')
              .select(select_clause)
              .to_sql

          execute("INSERT INTO approval_project_rules (project_id, approvals_required, created_at, updated_at, rule_type, name) #{select_sql}")
        end

        private

        def select_clause
          <<~SQL
              id, LEAST(#{MAX_VALUE}, approvals_before_merge),
              created_at, updated_at, #{::ApprovalProjectRule.rule_types[:any_approver]}, \'#{ApprovalRuleLike::ALL_MEMBERS}\'
          SQL
        end

        def project_approval_rules_not_exists_clause
          <<~SQL
              NOT EXISTS (SELECT 1 FROM approval_project_rules
                          WHERE approval_project_rules.project_id = projects.id)
          SQL
        end

        def execute(sql)
          @connection ||= ::ActiveRecord::Base.connection
          @connection.execute(sql)
        end
      end
    end
  end
end
