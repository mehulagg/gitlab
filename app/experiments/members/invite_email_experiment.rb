# frozen_string_literal: true

module Members
  class InviteEmailExperiment < ApplicationExperiment
    exclude { context.actor.created_by.blank? }
    exclude { context.actor.created_by.avatar_url.nil? }

    INVITE_TYPE = 'initial_email'

    def percentage_rollout
      return variant_names.first if Feature.enabled?(feature_flag_name, context.project_or_group, type: :experiment, default_enabled: :yaml)

      nil # Returning nil vs. :control is important for not caching and rollouts.
    end
  end
end
