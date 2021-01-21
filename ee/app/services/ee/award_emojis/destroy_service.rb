# frozen_string_literal: true

module EE
  module AwardEmojis
    module DestroyService
      extend ::Gitlab::Utils::Override

      private

      override :after_destroy
      def after_destroy(award)
        super

        ::Gitlab::StatusPage.trigger_publish(project, current_user, award)
      end
    end
  end
end
