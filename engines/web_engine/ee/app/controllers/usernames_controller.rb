# frozen_string_literal: true

class UsernamesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:suggest]

  feature_category :users

  def suggest
    if validate_params
      username = ::User.username_suggestion(params[:name])

      render json: { username: username }, status: :ok
    else
      render json: { message: 'Invalid input provided' }, status: :bad_request
    end
  end

  private

  def validate_params
    !params[:name].blank?
  end
end
