# frozen_string_literal: true

module EE
  module Projects
    module Operations
      module UpdateService
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :project_update_params
        def project_update_params
          super
            .merge(tracing_setting_params)
            .merge(status_page_setting_params)
        end

        private

        def tracing_setting_params
          attr = params[:tracing_setting_attributes]
          return {} unless attr

          destroy = attr[:external_url].blank?

          { tracing_setting_attributes: attr.merge(_destroy: destroy) }
        end

        def status_page_setting_params
          return {} unless attrs = params[:status_page_setting_attributes]

          destroy = attrs[:aws_s3_bucket_name].blank? &&
                    attrs[:aws_region].blank? &&
                    attrs[:aws_access_key].blank? &&
                    attrs[:aws_secret_key].blank? &&
                    attrs[:status_page_url].blank?

          { status_page_setting_attributes: attrs.merge(_destroy: destroy) }
        end
      end
    end
  end
end
