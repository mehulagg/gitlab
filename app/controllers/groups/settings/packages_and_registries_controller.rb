# frozen_string_literal: true

module Groups
  module Settings
    class PackagesAndRegistriesController < Groups::ApplicationController
      before_action :authorize_admin_group!

      def index
      end
    end
  end
end
