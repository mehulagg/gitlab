# frozen_string_literal: true

module Gitlab
  module Audit
    class ImpersonatedAuthor
      def initialize(user)
        @user = user
      end

      def id
        @user.id
      end

      def name
        @user.name
      end

      def current_sign_in_ip
        impersonator.current_sign_in_ip
      end

      def impersonated_by
        impersonator.name
      end

      def impersonated?
        true
      end

      private

      def impersonator
        @user.impersonator
      end
    end
  end
end
