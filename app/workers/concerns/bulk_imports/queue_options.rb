# frozen_string_literal: true

module BulkImports
  module QueueOptions
    extend ActiveSupport::Concern

    included do
      feature_category :importers

      sidekiq_options retry: false, dead: false
    end
  end
end
