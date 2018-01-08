class Projects::DeployKeysController < Projects::ApplicationController
  include RepositorySettingsRedirect
  respond_to :html

  # Authorize
  before_action :authorize_admin_project!
  before_action :authorize_update_deploy_key!, only: [:edit, :update]

  layout 'project_settings'

  def index
    respond_to do |format|
      format.html { redirect_to_repository_settings(@project) }
      format.json do
        render json: Projects::Settings::DeployKeysPresenter.new(@project, current_user: current_user).as_json
      end
    end
  end

  def new
    redirect_to_repository_settings(@project)
  end

  def create
    @key = DeployKeys::CreateService.new(current_user, create_params).execute

    if @key.valid? && @project.deploy_keys << @key
      log_audit_event(@key.title, action: :create)
    else
      flash[:alert] = @key.errors.full_messages.join(', ').html_safe
    end

    redirect_to_repository_settings(@project)
  end

  def edit
  end

  def update
    if deploy_key.update_attributes(update_params)
      flash[:notice] = 'Deploy key was successfully updated.'
      redirect_to_repository_settings(@project)
    else
      render 'edit'
    end
  end

  def enable
    load_key
    Projects::EnableDeployKeyService.new(@project, current_user, params).execute
    log_audit_event(@key.title, action: :create)

    respond_to do |format|
      format.html { redirect_to_repository_settings(@project) }
      format.json { head :ok }
    end
  end

  def disable
    deploy_key_project = @project.deploy_keys_projects.find_by(deploy_key_id: params[:id])
    return render_404 unless deploy_key_project

    load_key
    deploy_key_project.destroy!
    log_audit_event(@key.title, action: :destroy)

    respond_to do |format|
      format.html { redirect_to_repository_settings(@project) }
      format.json { head :ok }
    end
  end

  protected

  def deploy_key
    @deploy_key ||= DeployKey.find(params[:id])
  end

  def create_params
    params.require(:deploy_key).permit(:key, :title, :can_push)
  end

  def update_params
    params.require(:deploy_key).permit(:title, :can_push)
  end

  def authorize_update_deploy_key!
    access_denied! unless can?(current_user, :update_deploy_key, deploy_key)
  end

  def log_audit_event(key_title, options = {})
    AuditEventService.new(current_user, @project, options)
      .for_deploy_key(key_title).security_event
  end

  def load_key
    @key ||= current_user.accessible_deploy_keys.find(params[:id])
  end
end
