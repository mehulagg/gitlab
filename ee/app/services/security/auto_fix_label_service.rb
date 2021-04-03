# frozen_string_literal: true

module Security
  class AutoFixLabelService < BaseContainerService
    LABEL_PROPERTIES = {
      title: 'GitLab-auto-fix',
      color: '#FF8167',
      description: <<~DESCRIPTION.chomp
        Merge Requests created automatically by @GitLab-Security-Bot \
        as a remediation of a security vulnerability
      DESCRIPTION
    }.freeze

    def initialize(container:, current_user: nil, params: {})
      super

      @project = container
    end

    def execute
      label = ::Labels::FindOrCreateService
        .new(current_user, project, **LABEL_PROPERTIES)
        .execute(skip_authorization: true)

      ServiceResponse.success(payload: { label: label })
    end

    private

    attr_reader :project
  end
end
