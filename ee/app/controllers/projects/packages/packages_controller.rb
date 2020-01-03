# frozen_string_literal: true

module Projects
  module Packages
    class PackagesController < Projects::ApplicationController
      include PackagesAccess
      include SortingHelper

      before_action :authorize_destroy_package!, only: [:destroy]

      def index
        @packages = project.packages
                      .has_version
                      .processed
                      .sort_by_attribute(@sort = params[:sort] || 'created_desc')
                      .page(params[:page])
      end

      def show
        @package = project.packages.find(params[:id])
        @package_files = @package.package_files.recent
        @maven_metadatum = @package.maven_metadatum
        @composer_metadatum = @package.composer_metadatum
      end

      def destroy
        @package = project.packages.find(params[:id])
        @package.destroy

        redirect_to project_packages_path(@project), status: :found, notice: _('Package was removed')
      end
    end
  end
end
