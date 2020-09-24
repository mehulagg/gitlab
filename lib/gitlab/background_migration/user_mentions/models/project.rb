# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    module UserMentions
      module Models
        class Project < ApplicationRecord
          self.table_name = 'projects'

          include FeatureGate

          def default_issues_tracker?
            false
          end

          def external_issue_reference_pattern
            nil
          end

          def grafana_integration
            nil
          end
        end
      end
    end
  end
end
