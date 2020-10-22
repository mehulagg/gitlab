# frozen_string_literal: true

module DependencyProxyAuth
  extend ActiveSupport::Concern

  def respond_unauthorized_with_oauth!
    response.headers['WWW-Authenticate'] = ::DependencyProxy::Registry.authenticate_header
    render json: {}, status: :unauthorized
  end
end
