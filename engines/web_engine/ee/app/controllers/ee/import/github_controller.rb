# frozen_string_literal: true

module EE
  module Import
    module GithubController
      extend ::Gitlab::Utils::Override

      override :permitted_import_params
      def permitted_import_params
        super.push(:ci_cd_only)
      end

      override :extra_import_params
      def extra_import_params
        extra_params = super
        ci_cd_only = ::Gitlab::Utils.to_boolean(params[:ci_cd_only])

        extra_params[:ci_cd_only] = true if ci_cd_only
        extra_params
      end
    end
  end
end
