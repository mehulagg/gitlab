# frozen_string_literal: true

module EE
  module Groups
    module ApplicationController
      extend ActiveSupport::Concern

      prepended do
        before_action :record_invite_members_new_dropdown_experiment
      end

      def check_group_feature_available!(feature)
        render_404 unless group.feature_available?(feature)
      end

      def method_missing(method_sym, *arguments, &block)
        case method_sym.to_s
        when /\Acheck_(.*)_available!\z/
          check_group_feature_available!(Regexp.last_match(1).to_sym)
        else
          super
        end
      end

      private

      def record_invite_members_new_dropdown_experiment
        record_experiment_user(:invite_members_new_dropdown)
      end
    end
  end
end
