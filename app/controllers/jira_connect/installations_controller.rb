# frozen_string_literal: true

class JiraConnect::InstallationsController < JiraConnect::ApplicationController
  before_action :verify_qsh_claim!, only: :index

  def index
    { foo: 'bar' }
  end
end
