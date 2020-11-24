# frozen_string_literal: true

module Feature
  class MaintenanceCronWorker
    include ApplicationWorker
    include CronjobQueue

    queue_namespace :feature
    feature_category :feature

    AVAILBLE_SERVICES = [
      Feature::DeleteRedundantOverridingsService
    ].freeze

    def perform
      AVAILBLE_SERVICES.each do |klass|
        service = klass.new
        service.execute if service.available?
      end
    end
  end
end
