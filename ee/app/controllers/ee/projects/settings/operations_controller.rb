# frozen_string_literal: true

module EE
  module Projects
    module Settings
      module OperationsController
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        prepended do
          helper_method :status_page_setting

          private

          def status_page_setting
            @status_page_setting ||= project.status_page_setting || project.build_status_page_setting
          end

          def has_status_page_license?
            project.feature_available?(:status_page, current_user)
          end

          def sla_feature_available?
            ::IncidentManagement::IncidentSla.available_for?(@project)
          end

          def track_tracing_external_url
            external_url_previous_change = project&.tracing_setting&.external_url_previous_change
            return unless external_url_previous_change
            return unless external_url_previous_change[0].blank? && external_url_previous_change[1].present?

            ::Gitlab::Tracking.event('project:operations:tracing', "external_url_populated", user: current_user, project: project, namespace: project.namespace)
          end
        end

        override :permitted_project_params
        def permitted_project_params
          permitted_params = super

          if has_status_page_license?
            permitted_params.merge!(status_page_setting_params)
          end

          if sla_feature_available?
            incident_params = Array(permitted_params[:incident_management_setting_attributes])
            permitted_params[:incident_management_setting_attributes] = incident_params.push(*sla_timer_params)
          end

          permitted_params
        end

        def status_page_setting_params
          { status_page_setting_attributes: [:status_page_url, :aws_s3_bucket_name, :aws_region, :aws_access_key, :aws_secret_key, :enabled] }
        end

        def sla_timer_params
          [:sla_timer, :sla_timer_minutes]
        end

        override :track_events
        def track_events(result)
          super

          track_tracing_external_url if result[:status] == :success
        end
      end
    end
  end
end
