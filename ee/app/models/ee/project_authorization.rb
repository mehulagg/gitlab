# frozen_string_literal: true

module EE
  module ProjectAuthorization
    extend ActiveSupport::Concern

    class_methods do
      def visible_to_user_and_access_level(user, access_level)
        where(user: user).where('access_level >= ?', access_level)
      end

      def pluck_user_ids
        pluck(:user_id)
      end
    end
  end
end
