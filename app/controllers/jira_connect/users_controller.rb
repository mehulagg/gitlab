# frozen_string_literal: true

class JiraConnect::UsersController < ApplicationController
  feature_category :integrations

  layout 'devise_onboarding'

  def show
    @jira_app_link = params.delete(:return_to)
  end
end
