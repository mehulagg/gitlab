# frozen_string_literal: true

class Import::V2::GitlabGroupsController < ApplicationController
  before_action :ensure_group_import_enabled
  before_action :verify_blocked_uri, only: :status

  def configure
    session[access_token_key] = params[access_token_key]&.strip
    session[url_key] = params[url_key]

    redirect_to status_import_v2_gitlab_group_url
  end

  def status
    respond_to do |format|
      format.html
    end
  end

  private

  def import_params
    params.permit(access_token_key, url_key)
  end

  def ensure_group_import_enabled
    render_404 unless Feature.enabled?(:group_import_v2)
  end

  def access_token_key
    :gitlab_personal_access_token
  end

  def url_key
    :gitlab_url
  end

  def verify_blocked_uri
    Gitlab::UrlBlocker.validate!(
      session[url_key],
      {
        allow_localhost: allow_local_requests?,
        allow_local_network: allow_local_requests?,
        schemes: %w(http https)
      }
    )
  rescue Gitlab::UrlBlocker::BlockedUrlError => e
    session[access_token_key] = nil
    session[url_key] = nil

    redirect_to new_group_path, alert: _('Specified URL cannot be used: "%{reason}"') % { reason: e.message }
  end

  def allow_local_requests?
    Gitlab::CurrentSettings.allow_local_requests_from_web_hooks_and_services?
  end
end
