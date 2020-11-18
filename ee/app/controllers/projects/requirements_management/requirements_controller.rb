# frozen_string_literal: true

class Projects::RequirementsManagement::RequirementsController < Projects::ApplicationController
  include WorkhorseAuthorization

  EXTENSION_WHITELIST = ['csv'].freeze

  before_action :authorize_read_requirement!
  before_action :authorize_import_requirements!, only: [:import_csv]

  feature_category :requirements_management

  def index
    respond_to do |format|
      format.html
    end
  end

  def import_csv
    unless file_is_valid?(params[:file])
      flash[:alert] = _("You need to upload a valid CSV file (ending in .csv).")
      return redirect_to project_requirements_management_requirements_path(project)
    end

    if uploader = UploadService.new(project, params[:file]).execute
      RequirementsManagement::ImportCsvService.new(current_user, project, uploader.upload.retrieve_uploader).execute
      # This Service should be replaced with a worker once it is implemented
      # ImportRequirementsCsvWorker.perform_async(current_user.id, project.id, uploader.upload.id) # rubocop:disable CodeReuse/Worker

      flash[:notice] = _("Your requirements are being imported. Once finished, you'll get a confirmation email.")
    else
      flash[:alert] = _("File upload error.")
    end

    redirect_to project_requirements_management_requirements_path(project)
  end

  def uploader_class
    FileUploader
  end

  def extension_whitelist
    EXTENSION_WHITELIST
  end
end
