# frozen_string_literal: true

class Groups::DependencyProxyAuthController < ApplicationController
  feature_category :dependency_proxy

  skip_before_action :authenticate_user!

  def pre_request
    if request.headers['HTTP_AUTHORIZATION']
      render json: {}, status: :ok
    else
      response.headers['WWW-Authenticate'] = ::DependencyProxy::Registry.authenticate_header
      render json: json_error, status: :unauthorized
    end
  end

  private

  def json_error
    {
      errors: [
        { code: 401,
          message: 'access to the requested resource is not authorized' }
      ]
    }
  end
end
