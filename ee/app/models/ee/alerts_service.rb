# frozen_string_literal: true

module EE
  module AlertsService
    extend ActiveSupport::Concern

    prepended do
      boolean_accessor :opsgenie_mvc_enabled
      prop_accessor :opsgenie_mvc_target_url

      validates :opsgenie_mvc_target_url, presence: true, public_url: true,
        if: :opsgenie_mvc_enabled?
    end

    def opsgenie_mvc_available?
      return false if instance? || template?

      project.feature_available?(:opsgenie_integration)
    end
  end
end
