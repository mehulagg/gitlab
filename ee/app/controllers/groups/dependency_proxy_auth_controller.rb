# frozen_string_literal: true

class Groups::DependencyProxyAuthController < ApplicationController
  include DependencyProxyAuth

  feature_category :dependency_proxy

  skip_before_action :authenticate_user!

  def pre_request
    if request.headers['HTTP_AUTHORIZATION']
      render json: {}, status: :ok
    else
      respond_unauthorized_with_oauth!
    end
  end
end
