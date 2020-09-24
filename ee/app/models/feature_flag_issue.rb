# frozen_string_literal: true

class FeatureFlagIssue < ApplicationRecord
  self.table_name = 'operations_feature_flags_issues'

  belongs_to :feature_flag, class_name: '::Operations::FeatureFlag'
  belongs_to :issue
end
