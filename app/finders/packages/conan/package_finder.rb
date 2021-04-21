# frozen_string_literal: true

module Packages
  module Conan
    class PackageFinder
      include ::Packages::FinderHelper

      def initialize(current_user, params)
        @current_user = current_user
        @query = params[:query]
      end

      def execute
        if @query
          packages_visible_to_user(@current_user)
            .conan
            .with_name_like(@query)
            .order_name_asc
        end
      end
    end
  end
end
