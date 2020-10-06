# frozen_string_literal: true

class Profiles::TwoFactor::OtpApplicationsController < Profiles::ApplicationController
  skip_before_action :check_two_factor_requirement

  def show
    current_user.otp_secret = User.generate_otp_secret(32)

    unless current_user.otp_grace_period_started_at && two_factor_grace_period
      current_user.otp_grace_period_started_at = Time.current
    end

    Users::UpdateService.new(current_user, user: current_user).execute!

    if two_factor_authentication_required?
      two_factor_authentication_reason(
        global: lambda do
          flash.now[:alert] =
            _('The global settings require you to enable Two-Factor Authentication for your account.')
        end,
        group: lambda do |groups|
          flash.now[:alert] = groups_notification(groups)
        end
      )

      unless two_factor_grace_period_expired?
        grace_period_deadline = current_user.otp_grace_period_started_at + two_factor_grace_period.hours
        flash.now[:alert] = flash.now[:alert] + _(" You need to do this before %{grace_period_deadline}.") % { grace_period_deadline: l(grace_period_deadline) }
      end
    end

    @qr_code = build_qr_code
    @account_string = account_string
  end

  private

  def build_qr_code
    uri = current_user.otp_provisioning_uri(account_string, issuer: issuer_host)
    RQRCode.render_qrcode(uri, :svg, level: :m, unit: 3)
  end

  def account_string
    "#{issuer_host}:#{current_user.email}"
  end

  def issuer_host
    Gitlab.config.gitlab.host
  end

  def groups_notification(groups)
    group_links = groups.map { |group| view_context.link_to group.full_name, group_path(group) }.to_sentence
    leave_group_links = groups.map { |group| view_context.link_to (s_("leave %{group_name}") % { group_name: group.full_name }), leave_group_members_path(group), remote: false, method: :delete}.to_sentence

    s_(%{The group settings for %{group_links} require you to enable Two-Factor Authentication for your account. You can %{leave_group_links}.})
      .html_safe % { group_links: group_links.html_safe, leave_group_links: leave_group_links.html_safe }
  end
end
