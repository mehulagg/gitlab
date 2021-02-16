# frozen_string_literal: true

class JiraConnect::SubscriptionsController < JiraConnect::ApplicationController
  layout 'jira_connect'

  content_security_policy do |p|
    next if p.directives.blank?

    # rubocop: disable Lint/PercentStringArray
    script_src_values = Array.wrap(p.directives['script-src']) | %w('self' https://connect-cdn.atl-paas.net https://unpkg.com/jquery@3.3.1/)
    style_src_values = Array.wrap(p.directives['style-src']) | %w('self' 'unsafe-inline' https://unpkg.com/@atlaskit/)
    # rubocop: enable Lint/PercentStringArray

    p.frame_ancestors :self, 'https://*.atlassian.net'
    p.script_src(*script_src_values)
    p.style_src(*style_src_values)
  end

  before_action :allow_rendering_in_iframe, only: :index
  before_action :verify_qsh_claim!, only: :index
  before_action :authenticate_user!, only: :create
  before_action do
    push_frontend_feature_flag(:new_jira_connect_ui, type: :development, default_enabled: :yaml)
  end

  def index
    @installation = current_jira_installation
    @subscriptions = current_jira_installation.subscriptions.preload_namespace_route
  end

  def edit
    @installation = current_jira_installation
  end

  def update
    # Make sure instance_url uses HTTPS
    # current_jira_installation.update
  end

  def create
    result = create_service.execute

    if result[:status] == :success
      render json: { success: true }
    else
      render json: { error: result[:message] }, status: result[:http_status]
    end
  end

  def destroy
    subscription = current_jira_installation.subscriptions.find(params[:id])

    if subscription.destroy
      render json: { success: true }
    else
      render json: { error: subscription.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def create_service
    JiraConnectSubscriptions::CreateService.new(current_jira_installation, current_user, namespace_path: params['namespace_path'])
  end

  def allow_rendering_in_iframe
    response.headers.delete('X-Frame-Options')
  end
end
