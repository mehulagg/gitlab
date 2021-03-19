# frozen_string_literal: true

module DastOnDemandScans
  class ParamsCreateService < BaseContainerService
    include Gitlab::Utils::StrongMemoize

    def execute
      return ServiceResponse.error(message: 'Site Profile was not provided') unless dast_site.present?
      return ServiceResponse.error(message: 'Cannot run active scan against unvalidated target') unless active_scan_allowed?

      ServiceResponse.success(
        payload: default_config.merge(scanner_profile_config)
      )
    end

    private

    def active_scan_allowed?
      return true unless dast_scanner_profile&.full_scan_enabled?

      DastSiteValidationsFinder.new(
        project_id: container.id,
        state: :passed,
        url_base: url_base
      ).execute.present?
    end

    def branch
      strong_memoize(:branch) do
        params[:branch] || container.default_branch
      end
    end

    def dast_site
      strong_memoize(:dast_site) do
        params[:dast_site_profile]&.dast_site
      end
    end

    def dast_scanner_profile
      strong_memoize(:dast_scanner_profile) do
        params[:dast_scanner_profile]
      end
    end

    def url_base
      strong_memoize(:url_base) do
        DastSiteValidation.get_normalized_url_base(dast_site&.url)
      end
    end

    def default_config
      {
        branch: branch,
        target_url: dast_site&.url
      }
    end

    def scanner_profile_config
      return {} unless dast_scanner_profile

      {
        spider_timeout: dast_scanner_profile.spider_timeout,
        target_timeout: dast_scanner_profile.target_timeout,
        full_scan_enabled: dast_scanner_profile.full_scan_enabled?,
        use_ajax_spider: dast_scanner_profile.use_ajax_spider,
        show_debug_messages: dast_scanner_profile.show_debug_messages
      }
    end
  end
end
