# frozen_string_literal: true

module EE
  module Projects
    module ProjectMembersController
      extend ActiveSupport::Concern

      prepended do
        before_action :check_membership_lock!, only: [:create, :import, :apply_import]
      end

      def check_membership_lock!
        access_denied!('Membership is locked by group settings') if membership_locked?
      end
    end
  end
end
