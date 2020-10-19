# frozen_string_literal: true

module Namespaces
  class CheckExcessStorageSizeService < CheckStorageSizeService
    def initialize(namespace, user)
      super
      @root_storage_size = EE::Namespace::RootExcessStorageSize.new(root_namespace)
    end

    private

    def enforce_limit?
      root_storage_size.enforce_limit?
    end

    def usage_message
      if root_namespace.contains_locked_projects?
        if root_namespace.additional_purchased_storage_size == 0
          params = { locked_project_count: root_namespace.repository_size_excess_project_count, pluralized_project: n_('project', 'projects', root_namespace.repository_size_excess_project_count) }

          s_("NamespaceStorageSize|You have reached the free storage limit of 10GB on %{locked_project_count} %{pluralized_project}. To unlock them, please purchase additional storage" % params)
        else
          s_("NamespaceStorageSize|%{namespace_name} contains a locked project" % { namespace_name: root_namespace.name })
        end
      else
        s_("NamespaceStorageSize|You have reached %{usage_in_percent} of %{namespace_name}'s storage capacity (%{used_storage} of %{storage_limit})" % current_usage_params)
      end
    end

    def above_size_limit_message
      if root_namespace.additional_purchased_storage_size > 0
        s_("NamespaceStorageSize|You have consumed all of your additional storage, please purchase more to unlock your projects over the free 10GB limit. You can't %{base_message}" % { base_message: base_message })
      else
        s_("NamespaceStorageSize|Please purchase additional storage to unlock your projects over the free 10GB project limit. You can't %{base_message}" % { base_message: base_message })
      end
    end
  end
end
