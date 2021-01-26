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

        if params[:maintenance_mode] == false || params[:maintenance_mode_message] == ''
          params[:maintenance_mode_message] = nil
        end

        elasticsearch_namespace_ids = params.delete(:elasticsearch_namespace_ids)
        elasticsearch_project_ids = params.delete(:elasticsearch_project_ids)

        if result = super
          find_or_create_index
          update_elasticsearch_containers(ElasticsearchIndexedNamespace, elasticsearch_namespace_ids)
          update_elasticsearch_containers(ElasticsearchIndexedProject, elasticsearch_project_ids)
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

      private

      def should_auto_approve_blocked_users?
        super || user_cap_increased?
      end

      def user_cap_increased?
        return false unless application_setting.previous_changes.key?(:new_user_signups_cap)
        return false unless ::Feature.enabled?(:admin_new_user_signups_cap, default_enabled: true )

        previous_user_cap, current_user_cap = application_setting.previous_changes[:new_user_signups_cap]

        return false if previous_user_cap.nil?

        current_user_cap.nil? || current_user_cap > previous_user_cap
      end

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
