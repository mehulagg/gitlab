# frozen_string_literal: true

module EE
  module API
    module Entities
      module Namespace
        extend ActiveSupport::Concern

        prepended do
          can_update_limits = ->(namespace, opts) { ::Ability.allowed?(opts[:current_user], :update_subscription_limit, namespace) }
          can_admin_namespace = ->(namespace, opts) { ::Ability.allowed?(opts[:current_user], :admin_namespace, namespace) }

          expose :shared_runners_minutes_limit, if: can_update_limits
          expose :extra_shared_runners_minutes_limit, if: can_update_limits
          expose :additional_purchased_storage_size, if: can_update_limits
          expose :additional_purchased_storage_ends_on, if: can_update_limits
          expose :billable_members_count do |namespace, options|
            namespace.billable_members_count(options[:requested_hosted_plan])
          end
          expose :plan, if: can_admin_namespace do |namespace, _|
            namespace.actual_plan_name
          end
          expose :trial_ends_on, if: can_admin_namespace do |namespace, _|
            namespace.trial_ends_on
          end
          expose :trial, if: can_admin_namespace do |namespace, _|
            namespace.trial?
          end
        end
      end
    end
  end
end
