# frozen_string_literal: true

class TrialsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  layout 'trial'

  before_action :check_if_gl_com_or_dev
  before_action :authenticate_user!
  before_action :find_or_create_namespace, only: :apply
  before_action :record_user_for_group_only_trials_experiment, only: :select

  feature_category :purchase

  def new
    record_experiment_user(:remove_known_trial_form_fields, remove_known_trial_form_fields_context)
    record_experiment_user(:trimmed_skip_trial_copy)
    record_experiment_user(:trial_registration_with_social_signin, trial_registration_with_social_signin_context)
  end

  def select
  end

  def create_lead
    url_params = { glm_source: params[:glm_source], glm_content: params[:glm_content] }
    @result = GitlabSubscriptions::CreateLeadService.new.execute({ trial_user: company_params })

    render(:new) && return unless @result[:success]

    if params[:glm_source] == 'about.gitlab.com'
      record_experiment_user(:trial_onboarding_issues)
      return redirect_to(new_users_sign_up_group_path(url_params.merge(trial_onboarding_flow: true))) if experiment_enabled?(:trial_onboarding_issues)
    end

    redirect_to select_trials_url(url_params)
  end

  def apply
    return render(:select) if @namespace.invalid?

    @result = GitlabSubscriptions::ApplyTrialService.new.execute(apply_trial_params)

    if @result&.dig(:success)
      record_experiment_conversion_event(:remove_known_trial_form_fields)
      record_experiment_conversion_event(:trimmed_skip_trial_copy)
      record_experiment_conversion_event(:trial_registration_with_social_signin)

      redirect_to group_url(@namespace, { trial: true })
    else
      render :select
    end
  end

  protected

  # override the ConfirmEmailWarning method in order to skip
  def show_confirm_warning?
    false
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

  def record_user_for_group_only_trials_experiment
    record_experiment_user(:group_only_trials)
  end

  def remove_known_trial_form_fields_context
    {
      first_name_present: current_user.first_name.present?,
      last_name_present: current_user.last_name.present?,
      company_name_present: current_user.organization.present?
    }
  end

  def trial_registration_with_social_signin_context
    identities = current_user.identities.map(&:provider)

    {
      google_signon: identities.include?('google_oauth2'),
      github_signon: identities.include?('github')
    }
  end
end
