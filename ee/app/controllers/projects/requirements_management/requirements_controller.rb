# frozen_string_literal: true

class Projects::RequirementsManagement::RequirementsController < Projects::ApplicationController
  include WorkhorseAuthorization

  EXTENSION_WHITELIST = %w[csv].map(&:downcase).freeze

  before_action :authorize_read_requirement!
  before_action :authorize_import_access!, only: [:import_csv, :authorize]
  before_action do
    push_frontend_feature_flag(:import_requirements_csv, project)
  end

  feature_category :requirements_management

  def index
    respond_to do |format|
      format.html
    end
  end

  def import_csv
    verify_valid_file!

    if uploader = UploadService.new(project, params[:file]).execute
      RequirementsManagement::ImportRequirementsCsvWorker.perform_async(current_user.id, project.id, uploader.upload.id) # rubocop:disable CodeReuse/Worker

      flash[:notice] = _("Your requirements are being imported. Once finished, you'll receive a confirmation email.")
    else
      flash[:alert] = _("File upload error.")
    end

    redirect_to project_requirements_management_requirements_path(project)
  end

  def authorize_import_access!
    render_404 unless Feature.enabled?(:import_requirements_csv, project, default_enabled: false)

    return if can?(current_user, :import_requirements, project)

    if current_user || action_name == 'authorize'
      render_404
    else
      authenticate_user!
    end
  end

  def verify_valid_file!
    return if file_is_valid?(params[:file])

    supported_file_extensions = ".#{EXTENSION_WHITELIST.join(', .')}"
    flash[:alert] = _("The uploaded file was invalid. Supported file extensions are %{extensions}.") % { extensions: supported_file_extensions }

    redirect_to project_requirements_management_requirements_path(project)
  end

  def uploader_class
    FileUploader
  end

  def file_extension_whitelist
    EXTENSION_WHITELIST
  end
end
