# frozen_string_literal: true

class Terraform::ServicesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render json: '{ "modules.v1": "/api/v4/packages/terraform/v1/modules/" }'
  end
end
