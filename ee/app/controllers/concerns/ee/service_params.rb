# frozen_string_literal: true

module EE
  module ServiceParams
    extend ::Gitlab::Utils::Override

    ALLOWED_PARAMS_EE = [
      :issues_enabled,
      :jenkins_url,
      :multiproject_enabled,
      :pass_unstable,
      :project_name,
      :repository_url,
      :static_context,
      :vulnerabilities_enabled,
      :vulnerabilities_issuetype
    ].freeze

    override :allowed_service_params
    def allowed_service_params
      super + ALLOWED_PARAMS_EE
    end
  end
end
