# frozen_string_literal: true

module Ci
  class TriggerEntity < Grape::Entity
    include Gitlab::Routing
    include Gitlab::Allowable

    expose :has_token_exposed do |trigger|
      can?(options[:current_user], :admin_trigger, trigger)
    end
    expose :token do |trigger|
      can?(options[:current_user], :admin_trigger, trigger) ? trigger.token : trigger.short_token
    end

    expose :description
    expose :owner, using: UserEntity
    expose :last_used

    expose :can_access_project do |trigger|
      trigger.can_access_project?
    end
    expose :edit_project_trigger_path do |trigger|
      can?(options[:current_user], :admin_trigger, trigger) ? edit_project_trigger_path(options[:project], trigger) : nil
    end
    expose :project_trigger_path do |trigger|
      can?(options[:current_user], :manage_trigger, trigger) ? project_trigger_path(options[:project], trigger) : nil
    end
  end
end
