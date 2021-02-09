# frozen_string_literal: true

module EE
  module API
    module Namespaces
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          params :optional_list_params_ee do
            # Used only by GitLab.com
            optional :requested_hosted_plan, type: String, desc: "Name of the hosted plan requested by the customer"
          end

          override :custom_namespace_present_options
          def custom_namespace_present_options
            { requested_hosted_plan: params[:requested_hosted_plan] }
          end

          def update_namespace(namespace)
            update_attrs = declared_params(include_missing: false)

            # Reset last_ci_minutes_notification_at if customer purchased extra CI minutes.
            if params[:extra_shared_runners_minutes_limit].present?
              update_attrs[:last_ci_minutes_notification_at] = nil
              update_attrs[:last_ci_minutes_usage_notification_level] = nil
              ::Ci::Runner.instance_type.each(&:tick_runner_queue)
            end

            namespace.update(update_attrs)
          end
        end

        resource :namespaces, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
          helpers do
            params :gitlab_subscription_optional_attributes do
              optional :start_date, type: Date, desc: 'The date when subscription was started'
              optional :seats, type: Integer, desc: 'The number of seats purchased'
              optional :max_seats_used, type: Integer, desc: 'The max number of active users detected in the last month'
              optional :plan_code, type: String, desc: 'The code of the purchased plan'
              optional :end_date, type: Date, desc: 'The date when subscription expires'
              optional :auto_renew, type: Grape::API::Boolean, desc: 'Whether the subscription auto renews'
              optional :trial, type: Grape::API::Boolean, desc: 'Whether the subscription is trial'
              optional :trial_ends_on, type: Date, desc: 'The date when the trial expires'
              optional :trial_starts_on, type: Date, desc: 'The date when the trial starts'
            end
          end

          desc 'Update a namespace' do
            success Entities::Namespace
          end
          params do
            optional :shared_runners_minutes_limit, type: Integer, desc: "Pipeline minutes quota for this namespace"
            optional :extra_shared_runners_minutes_limit, type: Integer, desc: "Extra pipeline minutes for this namespace"
            optional :additional_purchased_storage_size, type: Integer, desc: "Additional storage size for this namespace"
            optional :additional_purchased_storage_ends_on, type: Date, desc: "End of subscription of the additional purchased storage"
            optional :gitlab_subscription_attributes, type: Hash do
              use :gitlab_subscription_optional_attributes
            end
          end
          put ':id' do
            authenticated_as_admin!

            namespace = find_namespace(params[:id])

            break not_found!('Namespace') unless namespace

            if update_namespace(namespace)
              present namespace, with: ::API::Entities::Namespace, current_user: current_user
            else
              render_validation_error!(namespace)
            end
          end

          desc 'Create a subscription for the namespace' do
            success ::EE::API::Entities::GitlabSubscription
          end
          params do
            use :gitlab_subscription_optional_attributes

            requires :start_date, type: Date, desc: 'The date when subscription was started'
          end
          post ":id/gitlab_subscription" do
            authenticated_as_admin!

            namespace = find_namespace!(params[:id])

            subscription_params = declared_params(include_missing: false)
            subscription_params[:trial_starts_on] ||= subscription_params[:start_date] if subscription_params[:trial]
            subscription = namespace.create_gitlab_subscription(subscription_params)
            if subscription.persisted?
              present subscription, with: ::EE::API::Entities::GitlabSubscription
            else
              render_validation_error!(subscription)
            end
          end

          desc 'Returns the subscription for the namespace' do
            success ::EE::API::Entities::GitlabSubscription
          end
          get ":id/gitlab_subscription" do
            namespace = find_namespace!(params[:id])
            authorize! :admin_namespace, namespace

            present namespace.gitlab_subscription || {}, with: ::EE::API::Entities::GitlabSubscription
          end

          desc 'Update the subscription for the namespace' do
            success ::EE::API::Entities::GitlabSubscription
          end
          params do
            use :gitlab_subscription_optional_attributes
          end
          put ":id/gitlab_subscription" do
            authenticated_as_admin!

            namespace = find_namespace!(params[:id])
            subscription = namespace.gitlab_subscription

            not_found!('GitlabSubscription') unless subscription

            subscription_params = declared_params(include_missing: false)
            subscription_params[:trial_starts_on] ||= subscription_params[:start_date] if subscription_params[:trial]

            if subscription.update(subscription_params)
              present subscription, with: ::EE::API::Entities::GitlabSubscription
            else
              render_validation_error!(subscription)
            end
          end
        end
      end
    end
  end
end
