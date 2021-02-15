# frozen_string_literal: true

module DastOnDemandScans
  class ParamsCreateService < BaseContainerService
    def execute
      return ServiceResponse.error(message: 'Site Profile was not provided') unless dast_site.present?
      return ServiceResponse.error(message: 'Cannot run active scan against unvalidated target') unless active_scan_allowed?

      ServiceResponse.success(
        payload: {
          params: default_config.merge(scanner_profile_config)
        }
      )
    rescue KeyError => err
      ServiceResponse.error(message: err.message.capitalize)
    end

    private

    def active_scan_allowed?
      return true unless dast_scanner_profile&.full_scan_enabled?

      dast_site_validation = DastSiteValidationsFinder.new(
        project_id: container.id,
        state: :passed,
        url_base: url_base
      ).execute.first

      dast_site_validation.present?
    end

    def dast_site
      @dast_site ||= params.fetch(:dast_site_profile)&.dast_site
    end

    def dast_scanner_profile
      @dast_scanner_profile ||= params[:dast_scanner_profile]
    end

    def url_base
      @url_base ||= DastSiteValidation.get_normalized_url_base(dast_site.url)
    end

    def default_config
      {
        branch: container.default_branch,
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
