# frozen_string_literal: true

class QaSessionsController < Devise::SessionsController
  before_action :ensure_qa_request!
  protect_from_forgery prepend: true, except: [:show, :create]

  # Renders a blank javascript where we can inject
  def show
    render body: 'Waiting for login...'
  end

  def create
    super
  end

  def ensure_qa_request!
    # Ensure only gitlab qa can request in this controller
  end
end
