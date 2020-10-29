# frozen_string_literal: true

module Projects
  module Security
    class VulnerabilitiesController < Projects::ApplicationController
      include SecurityDashboardsPermissions
      include IssuableActions
      include RendersNotes

      before_action :vulnerability, except: :index

      alias_method :vulnerable, :project

      feature_category :vulnerability_management

      respond_to :html

      def show
        pipeline = vulnerability.finding.pipelines.first
        @pipeline = pipeline if Ability.allowed?(current_user, :read_pipeline, pipeline)
        @gfm_form = true
      end

      def save_issue
        result = ::Issues::CreateFromVulnerabilityService
          .new(
            container: vulnerability.project,
            current_user: current_user,
            params: {
              vulnerability: vulnerability,
              link_type: ::Vulnerabilities::IssueLink.link_types[:created]
            })
          .execute

        if result[:status] == :success
          render json: issue_serializer.represent(result[:issue], only: [:web_url])
        else
          render json: result[:message], status: :unprocessable_entity
        end
      end

      def create_issue
        result = ::Issues::BuildFromVulnerabilityService
          .new(
            container: @vulnerability.project,
            current_user: current_user,
            params: {
              vulnerability: @vulnerability,
              link_type: ::Vulnerabilities::IssueLink.link_types[:created]
            })
          .execute

        if result[:status] == :success
          render json: issue_serializer.represent(result[:issue], only: [:web_url])
        else
          render json: result[:message], status: :unprocessable_entity
        end
      end

      private

      def vulnerability
        @issuable = @noteable = @vulnerability ||= vulnerable.vulnerabilities.find(params[:id])
      end

      alias_method :issuable, :vulnerability
      alias_method :noteable, :vulnerability

      def issue_serializer
        IssueSerializer.new(current_user: current_user)
      end

      def issue_params
        params.require(:issue).permit(
          *issue_params_attributes,
          sentry_issue_attributes: [:sentry_issue_identifier]
        )
      end
    
      def issue_params_attributes
        %i[
          title
          assignee_id
          position
          description
          confidential
          milestone_id
          due_date
          state_event
          task_num
          lock_version
          discussion_locked
        ] + [{ label_ids: [], assignee_ids: [], update_task: [:index, :checked, :line_number, :line_source] }]
      end
    
      def issue_create_params
        create_params = %i[
          issue_type
        ]
    
        params.require(:issue).permit(
          *create_params
        ).merge(issue_params)
      end
    end
  end
end
