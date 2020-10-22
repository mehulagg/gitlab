# frozen_string_literal: true

class Groups::DependencyProxyAuthController < ApplicationController
  feature_category :package_registry

  skip_before_action :authenticate_user!

  def pre_request
    Rails.logger.info '--------------PREREQUEST-----------------------------'
    Rails.logger.info request.env['HTTP_AUTHORIZATION']
    # TODO check Authorization header for Bearer token, if valid, return ok
    # TODO if no token, return 401 with auth realm
    if request.headers['HTTP_AUTHORIZATION']
      Rails.logger.info "$$$$$$$$$$$$$$$ TOKEN $$$$$$$$$$$$$$$$$"
      render json: {}, status: :ok
    else
      response.headers['WWW-Authenticate'] = "Bearer realm=\"http://gdk.test:3001/jwt/auth\",service=\"registry.docker.io\",scope=\"repository:library/hello-world:pull\""
      render json: test_json, status: :unauthorized
    end
    Rails.logger.info '++++++++++++++++END PREREQUEST++++++++++++++++++++'
  end

  def auth
    Rails.logger.info '---------------------AUTH-----------------------------'
    # Rails.logger.info request.headers.inspect
    @authentication_result = Gitlab::Auth::Result.new(nil, nil, :none, Gitlab::Auth.read_only_authentication_abilities)

    authenticate_with_http_basic do |login, password|
      @authentication_result = Gitlab::Auth.find_for_git_client(login, password, project: nil, ip: request.ip)
      Rails.logger.info @authentication_result.inspect
      Rails.logger.info @authentication_result.inspect

      if @authentication_result.failed?
        render_unauthorized
      end
    end
    Rails.logger.info "***********"
    Rails.logger.info @authentication_result.inspect
    Rails.logger.info "***********"
    Rails.logger.info '++++++++++++++++++++++++++++END AUTH++++++++++++++++++++++'
  end

  private

  def test_json
    {
      errors: [
        { code: 401,
          message: 'access to the requested resource is not authorized',
          detail: [
            { "Type" => 'repository', "Name" => 'image', 'Action' => 'pull' }
          ] }
      ]
    }
  end
end
