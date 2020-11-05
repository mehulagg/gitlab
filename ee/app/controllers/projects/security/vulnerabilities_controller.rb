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

      def show
        pipeline = vulnerability.finding.pipelines.first
        @pipeline = pipeline if Ability.allowed?(current_user, :read_pipeline, pipeline)
        @gfm_form = true
      end

      def create_issue
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

      private

      def vulnerability
        @issuable = @noteable = @vulnerability ||= vulnerable.vulnerabilities.find(params[:id])
      end

      alias_method :issuable, :vulnerability
      alias_method :noteable, :vulnerability

      def issue_serializer
        IssueSerializer.new(current_user: current_user)
      end
    end
  end
end
