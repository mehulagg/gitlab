# frozen_string_literal: true

module EE
  module Projects
    module ApplicationController
      extend ActiveSupport::Concern

      prepended do
        before_action :record_invite_members_new_dropdown_experiment
      end

      private

      def record_invite_members_new_dropdown_experiment
        record_experiment_user(:invite_members_new_dropdown)
      end
    end
  end
end
