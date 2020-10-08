# frozen_string_literal: true

module Namespaces
  class CheckStorageSizeService
    include ActiveSupport::NumberHelper
    include Gitlab::Allowable
    include Gitlab::Utils::StrongMemoize

    def initialize(namespace, user)
      @root_namespace = namespace.root_ancestor
      @root_storage_size = EE::Namespace::RootStorageSize.new(root_namespace)
      @user = user
    end

    def execute
      return ServiceResponse.success unless Feature.enabled?(:namespace_storage_limit, root_namespace) || Feature.enabled?(:additional_repo_storage_by_namespace, root_namespace)

      return handle_namespace_storage_limit if Feature.enabled?(:namespace_storage_limit, root_namespace)

      handle_additional_repo_storage_by_namespace
    end

    def handle_namespace_storage_limit
      return ServiceResponse.success if alert_level(root_storage_size.usage_ratio) == :none

      if root_storage_size.above_size_limit?
        ServiceResponse.error(message: above_size_limit_message, payload: payload)
      else
        ServiceResponse.success(payload: payload)
      end
    end

    def handle_additional_repo_storage_by_namespace
      return ServiceResponse.success if alert_level(per_project_usage_ratio) == :none

      payload = {
          explanation_message: 'This mesage needs to contain CTA and number of projects used',
          usage_message: 'This message explains what is wrong',
          alert_level: alert_level(per_project_usage_ratio),
          root_namespace: root_namespace
      }
      ServiceResponse.error(message: "over additional repo storage", payload: payload)
    end

    def per_project_usage_ratio
      puts('checking usage ratio')
      return 1 if root_namespace.additional_purchased_storage_size == 0 && root_namespace.total_repository_size_excess > 0
      return 0 if root_namespace.additional_purchased_storage_size == 0

      root_namespace.total_repository_size_excess / root_namespace.additional_purchased_storage_size
    end

    private

    attr_reader :root_namespace, :root_storage_size, :user

    USAGE_THRESHOLDS = {
      none: 0.0,
      info: 0.5,
      warning: 0.75,
      alert: 0.95,
      error: 1.0
    }.freeze

    def payload
      return {} unless can?(user, :admin_namespace, root_namespace)

      {
        explanation_message: explanation_message,
        usage_message: usage_message,
        alert_level: alert_level(root_storage_size.usage_ratio),
        root_namespace: root_namespace
      }
    end

    def explanation_message
      root_storage_size.above_size_limit? ? above_size_limit_message : below_size_limit_message
    end

    def usage_message
      s_("You reached %{usage_in_percent} of %{namespace_name}'s storage capacity (%{used_storage} of %{storage_limit})" % current_usage_params)
    end

    def alert_level(usage_ratio)
      strong_memoize(:alert_level) do
        current_level = USAGE_THRESHOLDS.each_key.first

        USAGE_THRESHOLDS.each do |level, threshold|
          current_level = level if usage_ratio >= threshold
        end

        current_level
      end
    end

    def below_size_limit_message
      s_("If you reach 100%% storage capacity, you will not be able to: %{base_message}" % { base_message: base_message } )
    end

    def above_size_limit_message
      s_("%{namespace_name} is now read-only. You cannot: %{base_message}" % { namespace_name: root_namespace.name, base_message: base_message })
    end

    def base_message
      s_("push to your repository, create pipelines, create issues or add comments. To reduce storage capacity, delete unused repositories, artifacts, wikis, issues, and pipelines.")
    end

    def current_usage_params
      {
        usage_in_percent: number_to_percentage(root_storage_size.usage_ratio * 100, precision: 0),
        namespace_name: root_namespace.name,
        used_storage: formatted(root_storage_size.current_size),
        storage_limit: formatted(root_storage_size.limit)
      }
    end

    def formatted(number)
      number_to_human_size(number, delimiter: ',', precision: 2)
    end
  end
end
