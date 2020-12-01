# frozen_string_literal: true

module EE
  module ApplicationSettings
    module UpdateService
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      override :execute
      def execute
        # Repository size limit comes as MB from the view
        limit = params.delete(:repository_size_limit)
        application_setting.repository_size_limit = ::Gitlab::Utils.try_megabytes_to_bytes(limit) if limit

        elasticsearch_namespace_ids = params.delete(:elasticsearch_namespace_ids)
        elasticsearch_project_ids = params.delete(:elasticsearch_project_ids)

        previous_user_cap = application_setting.new_user_signups_cap

        if result = super
          find_or_create_index
          update_elasticsearch_containers(ElasticsearchIndexedNamespace, elasticsearch_namespace_ids)
          update_elasticsearch_containers(ElasticsearchIndexedProject, elasticsearch_project_ids)
          auto_approve_blocked_users(previous_user_cap)
        end

        result
      end

      def update_elasticsearch_containers(klass, new_container_ids)
        return unless application_setting.elasticsearch_limit_indexing?
        return if new_container_ids.nil?

        new_container_ids = new_container_ids.split(',').map(&:to_i) unless new_container_ids.is_a?(Array)

        # Destroy any containers that have been removed. This runs callbacks, etc
        klass.remove_all(except: new_container_ids)

        # Disregard any duplicates that are already present
        new_container_ids -= klass.target_ids

        # Add new containers
        new_container_ids.each { |id| klass.create!(klass.target_attr_name => id) }
      end

      def auto_approve_blocked_users(previous_user_cap)
        return if ::Feature.disabled?(:admin_new_user_signups_cap)
        return if previous_user_cap.nil?

        current_user_cap = application_setting.new_user_signups_cap

        if current_user_cap.nil? || current_user_cap > previous_user_cap
          ApproveBlockedUsersWorker.perform_async(current_user.id)
        end
      end

      private

      def find_or_create_index
        # The order of checks is important. We should not attempt to create a new index
        # unless elasticsearch_indexing is enabled
        return unless application_setting.elasticsearch_indexing
        return if ::Gitlab::Elastic::Helper.default.index_exists?

        ::Gitlab::Elastic::Helper.default.create_empty_index
      end
    end
  end
end
