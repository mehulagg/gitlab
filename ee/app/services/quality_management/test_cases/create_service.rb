# frozen_string_literal: true

module QualityManagement
  module TestCases
    class CreateService < BaseService
      ISSUE_TYPE = 'test_case'

      def initialize(project, current_user, title:, description: nil, label_ids: [])
        super(project, current_user)

        @title = title
        @description = description
        @label_ids = label_ids
      end

      def execute
        return error(_('Test cases are not available for this project')) unless can_create_test_cases?

        issue = Issues::CreateService.new(
          project,
          current_user,
          issue_type: ISSUE_TYPE,
          title: title,
          description: description,
          label_ids: label_ids
        ).execute

        return error(issue.errors.full_messages.to_sentence, issue) unless issue.valid?

        success(issue)
      end

      private

      attr_reader :title, :description, :label_ids

      def success(issue)
        ServiceResponse.success(payload: { issue: issue })
      end

      def error(message, issue = nil)
        ServiceResponse.error(payload: { issue: issue }, message: message)
      end

      def can_create_test_cases?
        project.feature_available?(:quality_management) && Feature.enabled?(:quality_test_cases, project, default_enabled: true)
      end
    end
  end
end
