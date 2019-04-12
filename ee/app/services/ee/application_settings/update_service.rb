# frozen_string_literal: true

module EE
  module ApplicationSettings
    module UpdateService
      extend ::Gitlab::Utils::Override
      extend ActiveSupport::Concern

      override :execute
      def execute
        # Repository size limit comes as MB from the view
        limit = params.delete(:repository_size_limit)
        application_setting.repository_size_limit = ::Gitlab::Utils.try_megabytes_to_bytes(limit) if limit

        super
      end
    end
  end
end
