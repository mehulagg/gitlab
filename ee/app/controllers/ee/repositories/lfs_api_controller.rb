# frozen_string_literal: true

module EE
  module Repositories
    module LfsApiController
      extend ::Gitlab::Utils::Override
      include GitlabRoutingHelper

      override :batch_operation_disallowed?
      def batch_operation_disallowed?
        super_result = super
        return true if super_result && !::Gitlab::Geo.enabled?

        if super_result && ::Gitlab::Geo.enabled?
          return true if !::Gitlab::Geo.primary? && !::Gitlab::Geo.secondary?
          return true if ::Gitlab::Geo.secondary? && !::Gitlab::Geo.primary_node_configured?
        end

        false
      end

      override :upload_http_url_to_repo
      def upload_http_url_to_repo
        return geo_primary_http_url_to_repo(project) if ::Gitlab::Geo.primary?

        super
      end

      override :lfs_read_only_message
      def lfs_read_only_message
        return super unless ::Gitlab::Geo.secondary_with_primary?

        translation = _('You cannot write to a read-only secondary GitLab Geo instance. Please use %{link_to_primary_node} instead.')
        message = translation % { link_to_primary_node: geo_primary_default_url_to_repo(project) }
        message.html_safe
      end
    end
  end
end
