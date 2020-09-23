# frozen_string_literal: true

class TrialsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  layout 'trial'

  before_action :check_if_gl_com_or_dev
  before_action :authenticate_user!
  before_action :find_or_create_namespace, only: :apply

  def new
  end

  def select
  end

  def create_lead
    @result = GitlabSubscriptions::CreateLeadService.new.execute({ trial_user: company_params })

    if @result[:success]
      redirect_to select_trials_url(glm_source: params[:glm_source], glm_content: params[:glm_content])
    else
      render :new
    end
  end

  def apply
    return render(:select) if @namespace.invalid?

    @result = GitlabSubscriptions::ApplyTrialService.new.execute(apply_trial_params)

    if @result&.dig(:success)
      redirect_to group_url(@namespace, { trial: true })
    else
      render :select
    end
  end

  private

  def authenticate_user!
    return if current_user

    redirect_to new_trial_registration_path, alert: I18n.t('devise.failure.unauthenticated')
  end

  def company_params
    params.permit(:company_name, :company_size, :first_name, :last_name, :phone_number, :number_of_users, :country)
          .merge(extra_params)
  end

  def extra_params
    attrs = {}
    attrs[:work_email] = current_user.email
    attrs[:uid] = current_user.id
    attrs[:skip_email_confirmation] = true
    attrs[:gitlab_com_trial] = true
    attrs[:provider] = 'gitlab'
    attrs[:newsletter_segment] = current_user.email_opted_in

    attrs
  end

  def apply_trial_params
    gl_com_params = { gitlab_com_trial: true, sync_to_gl: true }

    {
      trial_user: params.permit(:namespace_id, :trial_entity, :glm_source, :glm_content).merge(gl_com_params),
      uid: current_user.id
    }
  end

  def find_or_create_namespace
    @namespace = if find_namespace?
                   current_user.namespaces.find_by_id(params[:namespace_id])
                 elsif can_create_group?
                   create_group
                 end

    render_404 unless @namespace
  end

  def find_namespace?
    params[:namespace_id].present? && params[:namespace_id] != '0'
  end

  def can_create_group?
    params[:new_group_name].present? && can?(current_user, :create_group)
  end

  def create_group
    name = sanitize(params[:new_group_name])
    group = Groups::CreateService.new(current_user, name: name, path: Namespace.clean_path(name.parameterize)).execute

    params[:namespace_id] = group.id if group.persisted?

    group
  end
end
