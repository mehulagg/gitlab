# frozen_string_literal: true

module Gitlab
  module JiraImport
    module QueueOptions
      extend ActiveSupport::Concern

      included do
        queue_namespace :jira_importer
        feature_category :importers
      end
    end
  end
end
