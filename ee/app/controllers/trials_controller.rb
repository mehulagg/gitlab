# frozen_string_literal: true

class TrialsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper

  layout 'trial'

  before_action :check_if_gl_com_or_dev
  before_action :authenticate_user!
  before_action :find_or_create_namespace, only: :apply
  before_action :find_namespace, only: [:extend_trial, :reactivate_trial]
  before_action :authenticate_owner!, only: [:extend_trial, :reactivate_trial]


  feature_category :purchase

  def new
    record_experiment_user(:remove_known_trial_form_fields, remove_known_trial_form_fields_context)
  end

  def extend_trial
    # return redirect_to "http://192.168.0.64:3000"
    # return head 200
    # return

    # require 'pry'
    # binding.pry
    puts "X" * 100
    pp @namespace.can_extend?
    pp @namespace.invalid?

    return render_403 unless @namespace.can_extend?

    return render_403 if @namespace.invalid?

    @result = GitlabSubscriptions::ExtendTrialService.new.execute(extend_reactivate_trial_params)


    pp @result

    if @result&.dig(:success)
      head 200
      # redirect_to group_url(@namespace, { trial: true })
    else
      render_403
    end

    # if @namespace.gitlab_subscription.extend_trial
    #   head 200
    # else
    #   render_403 #403? or other code? error message?
    # end
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
      record_experiment_user(:remove_known_trial_form_fields, namespace_id: @namespace.id)
      record_experiment_user(:trial_onboarding_issues, namespace_id: @namespace.id)
      record_experiment_conversion_event(:remove_known_trial_form_fields)
      record_experiment_conversion_event(:trial_onboarding_issues)

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

  def authenticate_owner!
    pp @namespace.owners
    pp current_user
    pp @namespace.owners.include?(current_user)

    render_403 unless @namespace.owners.include?(current_user)
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

  def extend_reactivate_trial_params
    apply_trial_params
  end

  def find_or_create_namespace
    @namespace = if find_namespace?
                   current_user.namespaces.find_by_id(params[:namespace_id])
                 elsif can_create_group?
                   create_group
                 end

    render_404 unless @namespace
  end

  def find_namespace
    # require 'pry'
    # binding.pry

    @namespace = if find_namespace?
                   current_user.namespaces.find_by_id(params[:namespace_id])
                 end

    puts "T" * 100
    pp params
    pp @namespace
    pp @namespace.gitlab_subscription
    raise 'failed to find namespace from method `find_namespace`' unless @namespace

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

  def remove_known_trial_form_fields_context
    {
      first_name_present: current_user.first_name.present?,
      last_name_present: current_user.last_name.present?,
      company_name_present: current_user.organization.present?
    }
  end
end
