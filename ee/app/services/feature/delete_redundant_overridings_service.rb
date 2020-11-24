# frozen_string_literal: true

module Feature
  class DeleteRedundantOverridingsService < BaseService
    def execute
      cleanable_flags.each do |cleanable_flag|
        callout("Deleting the redundant overriding for #{flag.name}", flag)
        Feature.remove(cleanable_flag.name)
      end
    end

    def available?
      Feature.enabled?(:feature_delete_redundant_overridings_service)
    end
  end
end
