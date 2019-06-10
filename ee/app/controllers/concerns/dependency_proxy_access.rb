# frozen_string_literal: true

module DependencyProxyAccess
  extend ActiveSupport::Concern

  included do
    before_action :verify_dependency_proxy_enabled!
    before_action :authorize_read_dependency_proxy!
  end

  private

  def verify_dependency_proxy_enabled!
    render_404 unless Gitlab.config.dependency_proxy.enabled &&
        group.feature_available?(:dependency_proxy)
  end

  def authorize_read_dependency_proxy!
    access_denied! unless can?(current_user, :read_dependency_proxy, group)
  end
end
