# frozen_string_literal: true

module Projects
  module Registry
    class RepositoriesController < ::Projects::Registry::ApplicationController
      include PackagesHelper

      before_action :authorize_update_container_image!, only: [:destroy]

      def index
      end

      # The show action renders index to allow frontend routing to work on page refresh
      def show
        render :index
      end

      def destroy
        image.delete_scheduled!
        DeleteContainerRepositoryWorker.perform_async(current_user.id, image.id) # rubocop:disable CodeReuse/Worker
        track_package_event(:delete_repository, :container)

        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      def image
        @image ||= project.container_repositories.find(params[:id])
      end
    end
  end
end
