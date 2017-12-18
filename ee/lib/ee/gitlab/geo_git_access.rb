module EE
  module Gitlab
    module GeoGitAccess
      include ::Gitlab::ConfigHelper
      include ::EE::GitlabRoutingHelper

      GEO_SERVER_DOCS_URL = 'https://docs.gitlab.com/ee/gitlab-geo/using_a_geo_server.html'.freeze

      protected

      def project_or_wiki
        @project
      end

      private

      def push_to_read_only_message
        message = super

        if ::Gitlab::Geo.secondary_with_primary?
          message += " Please use the Primary node URL: #{geo_primary_url_to_repo}. Documentation: #{GEO_SERVER_DOCS_URL}"
        end

        message
      end

      def geo_primary_url_to_repo
        case protocol
        when 'ssh'
          geo_primary_ssh_url_to_repo(project_or_wiki)
        else
          geo_primary_http_url_to_repo(project_or_wiki)
        end
      end
    end
  end
end
