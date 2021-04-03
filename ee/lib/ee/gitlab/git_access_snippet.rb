# frozen_string_literal: true

module EE
  module Gitlab
    module GitAccessSnippet
      extend ::Gitlab::Utils::Override

      private

      override :check_download_access!
      def check_download_access!
        return if geo?

        super
      end

      override :check_push_access!
      def check_push_access!
        return if geo?

        super
      end

      override :allowed_actor?
      def allowed_actor?
        super || geo?
      end
    end
  end
end
