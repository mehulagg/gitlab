# frozen_string_literal: true

module Gitlab
  module BulkImport
    module QueueOptions
      extend ActiveSupport::Concern

      included do
        queue_namespace :bulk_import
        feature_category :importers

        sidekiq_options retry: false
      end
    end
  end
end
