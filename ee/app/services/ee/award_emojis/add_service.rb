# frozen_string_literal: true

module EE
  module AwardEmojis
    module AddService
      extend ::Gitlab::Utils::Override

      private

      override :after_create
      def after_create(award)
        super

        ::Gitlab::StatusPage.trigger_publish(project, current_user, award)
      end
    end
  end
end
