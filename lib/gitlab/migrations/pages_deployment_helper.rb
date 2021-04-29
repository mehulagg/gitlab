# frozen_string_literal: true

module Gitlab
  module Migrations
    class PagesDeploymentHelper < BaseHelper
      private

      def items_stored_locally
        ::PagesDeployment.with_files_stored_locally
      end

      def items_stored_remotely
        ::PagesDeployment.with_files_stored_remotely
      end
    end
  end
end
