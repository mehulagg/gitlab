# frozen_string_literal: true

module Namespaces
  class CheckStorageSizeService
    include ActiveSupport::NumberHelper
    include Gitlab::Allowable
    include Gitlab::Utils::StrongMemoize

    def initialize(namespace, user, ignore_none_level = false)
      @root_namespace = namespace.root_ancestor
      @root_storage_size = EE::Namespace::RootStorageSize.new(root_namespace)
      @user = user
      @ignore_none_level = ignore_none_level
    end

    def execute
      return ServiceResponse.success unless Feature.enabled?(:namespace_storage_limit, root_namespace)
      return ServiceResponse.success if alert_level == :none && !@ignore_none_level

      if root_storage_size.above_size_limit?
        ServiceResponse.error(message: above_size_limit_message, payload: payload)
      else
        ServiceResponse.success(payload: payload)
      end
    end

    private

    attr_reader :root_namespace, :root_storage_size, :user

    def usage_thresholds
      {}.tap do |thresholds|
        thresholds[:none] = 0.0 unless @ignore_none_level
        thresholds[:info] = 0.5
        thresholds[:warning] = 0.75
        thresholds[:alert] = 0.95
        thresholds[:error] = 1.0
      end
    end

    def payload
      return {} unless can?(user, :admin_namespace, root_namespace)

      {
        explanation_message: explanation_message,
        short_explanation_message: short_explanation_message(root_namespace),
        usage_message: usage_message,
        alert_level: alert_level,
        root_namespace: root_namespace
      }
    end

    def explanation_message
      root_storage_size.above_size_limit? ? above_size_limit_message : below_size_limit_message
    end

    def usage_message
      s_("You reached %{usage_in_percent} of %{namespace_name}'s storage capacity (%{used_storage} of %{storage_limit})" % current_usage_params)
    end

    def alert_level
      strong_memoize(:alert_level) do
        usage_ratio = root_storage_size.usage_ratio
        current_level = usage_thresholds.each_key.first

        usage_thresholds.each do |level, threshold|
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

    def short_explanation_message(namespace)
      namespace.root_ancestor.additional_purchased_storage_size > 0 ? purchased_storage_messages(alert_level) : no_purchased_storage_messages(alert_level)
    end

    def purchased_storage_messages(alert_level)
      if alert_level == :error
        s_('You have consumed all of your additional storage, please purchase more to unlock your projects over the free 10GB limit.' % { size_limit: size_limit })
      elsif alert_level == :alert || alert_level == :warning
        'Your purchased storage is running low. To avoid locked projects, please purchase more storage.'
      else
        s_('When you purchase additional storage, we automatically unlock projects that were locked when you reached the %{size_limit} limit.' % { size_limit: size_limit })
      end
    end

    def no_purchased_storage_messages(alert_level)
      if alert_level == :error
        s_('You have reached the free storage limit of %{size_limit} %{namespace}. To unlock them, please purchase additional storage.' % { size_limit: size_limit, namespace: @root_namespace })
      elsif alert_level == :alert || alert_level == :warning
        'Your purchased storage is running low. To avoid locked projects, please purchase more storage.'
      else
        s_('When you purchase additional storage, we automatically unlock projects that were locked when you reached the %{size_limit} limit.' % { size_limit: size_limit })
      end
    end

    def size_limit
      formatted(@root_namespace.actual_size_limit)
    end

    def current_usage_params
      {
        usage_in_percent: number_to_percentage(root_storage_size.usage_ratio * 100, precision: 0),
        namespace_name: root_namespace.name,
        used_storage: formatted(root_storage_size.current_size || 0),
        storage_limit: formatted(root_storage_size.limit)
      }
    end

    def formatted(number)
      number_to_human_size(number, delimiter: ',', precision: 2)
    end
  end
end
