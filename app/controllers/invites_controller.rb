# frozen_string_literal: true

class InvitesController < ApplicationController
  include Gitlab::Utils::StrongMemoize

  before_action :member
  before_action :ensure_member_exists
  before_action :invite_details
  before_action :set_invite_type, only: :show
  skip_before_action :authenticate_user!, only: :decline

  helper_method :member?, :current_user_matches_invite?

  respond_to :html

  feature_category :authentication_and_authorization

  def show
    experiment('members/invite_email', actor: member).track(:opened) if initial_invite_email?

    accept if skip_invitation_prompt?
  end

  def accept
    if member.accept_invite!(current_user)
      experiment('members/invite_email', actor: member).track(:accepted) if initial_invite_email?
      session.delete(:invite_type)

      redirect_to invite_details[:path], notice: _("You have been granted %{member_human_access} access to %{title} %{name}.") %
        { member_human_access: member.human_access, title: invite_details[:title], name: invite_details[:name] }
    else
      redirect_back_or_default(options: { alert: _("The invitation could not be accepted.") })
    end
  end

  def decline
    if member.decline_invite!
      return render layout: 'signup_onboarding' if !current_user && member.invite_to_unknown_user? && member.created_by

      path =
        if current_user
          dashboard_projects_path
        else
          new_user_session_path
        end

      redirect_to path, notice: _("You have declined the invitation to join %{title} %{name}.") %
        { title: invite_details[:title], name: invite_details[:name] }
    else
      redirect_back_or_default(options: { alert: _("The invitation could not be declined.") })
    end
  end

  private

  def set_invite_type
    session[:invite_type] = params[:invite_type] if params[:invite_type].in?([Members::InviteEmailExperiment::INVITE_TYPE])
  end

  def initial_invite_email?
    session[:invite_type] == Members::InviteEmailExperiment::INVITE_TYPE
  end

  def skip_invitation_prompt?
    !member? && current_user_matches_invite?
  end

  def current_user_matches_invite?
    @member.invite_email == current_user.email
  end

  def member?
    strong_memoize(:is_member) do
      @member.source.users.include?(current_user)
    end
  end

  def member
    strong_memoize(:member) do
      @token = params[:id]
      Member.find_by_invite_token(@token)
    end
  end

  def ensure_member_exists
    return if member

    render_404
  end

  def authenticate_user!
    return if current_user

    notice = ["To accept this invitation, sign in"]
    notice << "or create an account" if Gitlab::CurrentSettings.allow_signup?
    notice = notice.join(' ') + "."

    redirect_params = member ? { invite_email: member.invite_email } : {}

    store_location_for :user, request.fullpath

    redirect_to new_user_session_path(redirect_params), notice: notice
  end

  def invite_landing_url(member)
    if experiment_enabled?(:invited_users_land_on_activity_page, member)
      case member.source
      when Project
        project_activity_url(member.source)
      when Group
        group_activity_url(member.source)
      end
    else
      case member.source
      when Project
        project_url(member.source)
      when Group
        group_url(member.source)
      end
    end
  end

  def invite_details
    @invite_details ||= case member.source
                        when Project
                          {
                            name: member.source.full_name,
                            url: invite_landing_url(member),
                            title: _("project"),
                            path: project_path(member.source)
                          }
                        when Group
                          {
                            name: member.source.name,
                            url: invite_landing_url(member),
                            title: _("group"),
                            path: group_path(member.source)
                          }
                        end
  end
end
