# frozen_string_literal: true

class RegistrationGroupInviteExperiment < ApplicationExperiment
  private

  def resolve_variant_name
    # we are overriding here so that when we add another experiment
    # we can merely add that variant and check of feature flag here
    if Feature.enabled?(:registration_group_invite, self, type: :experiment, default_enabled: :yaml)
      :invite_page
    else
      nil # :control
    end
  end
end
