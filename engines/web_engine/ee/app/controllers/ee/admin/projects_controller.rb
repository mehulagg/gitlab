# frozen_string_literal: true

module EE
  module Admin
    module ProjectsController
      extend ActiveSupport::Concern

      prepended do
        before_action :limited_actions_message!, only: :show
      end
    end
  end
end
