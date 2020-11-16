# frozen_string_literal: true

module EE
  module Projects
    module IssuesController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        include DescriptionDiffActions

        before_action :whitelist_query_limiting_ee, only: [:update]

        feature_category :issue_tracking, [:delete_description_version, :description_diff]
      end

      def new
        populate_vulnerability
        super
      end

      private

      def issue_params_attributes
        attrs = super
        attrs.unshift(:weight) if project.feature_available?(:issue_weights)
        attrs.unshift(:epic_id) if project.group&.feature_available?(:epics)

        attrs
      end

      override :finder_options
      def finder_options
        options = super

        return super if project.feature_available?(:issue_weights)

        options.reject { |key| key == 'weight' }
      end

      def whitelist_query_limiting_ee
        ::Gitlab::QueryLimiting.whitelist('https://gitlab.com/gitlab-org/gitlab/issues/4794')
      end

      def build_issue(build_params)
        if vulnerability_id
          ::Issues::BuildFromVulnerabilityService.new(project, current_user, { vulnerability: vulnerability })
        else
          super
        end
      end

      def create_vulnerability_issue_link(issue)
        return unless vulnerability && issue.valid?

        result = VulnerabilityIssueLinks::CreateService.new(
          current_user,
          vulnerability,
          issue,
          link_type: Vulnerabilities::IssueLink.link_types[:created]
        ).execute

        flash[:alert] = _('Unable to create link to vulnerability') if result.status == :error
      end

      def vulnerability
        project.vulnerabilities.find(vulnerability_id) if vulnerability_id
      end

      def vulnerability_id
        params[:vulnerability_id]
      end
    end
  end
end
