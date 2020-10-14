# frozen_string_literal: true

module Namespaces
  class CheckExcessStorageSizeService < CheckStorageSizeService
    ONE_GIGABYTE = 10_000

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
          text = "You have reached the free storage limit of 10GB on %{locked_project_count} projects. To unlock them, please purchase additional storage"
          s_(text % { locked_project_count: root_namespace.repository_size_excess_project_count })
        else
          s_("%{namespace_name} contains a locked project" % { namespace_name: root_namespace.name })
        end
      else
        s_("You have reached %{usage_in_percent} of %{namespace_name}'s storage capacity (%{used_storage} of %{storage_limit})" % current_usage_params)
      end
    end

    def above_size_limit_message
      text = if root_namespace.additional_purchased_storage_size > 0
               "You have consumed all of your additional storage, please purchase more to unlock your projects over the free 10GB limit.\r\nYou can't %{base_message}"
             else
               "Please purchase additional storage to unlock your projects at the 10GB project limit.\r\nYou can't %{base_message}"
             end

      s_(text % { base_message: base_message })
    end
  end
end
