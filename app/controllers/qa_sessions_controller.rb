# frozen_string_literal: true

class QaSessionsController < Devise::SessionsController
  prepend_before_action :ensure_qa_running!
  # prepend_ is important, normal before_action would mean that
  # the user is authenticated right away if the username/password params
  # are correct and it runs this filter only after a session is created.
  def create
    if current_user
      redirect_to after_sign_in_path_for(current_user)
    else
      head :unauthorized # when the username/password is invalid and login fails
    end
  end
  def ensure_qa_running!
    return head :forbidden unless ENV['GITLAB_QA_FORMLESS_LOGIN_TOKEN'].present?
    return head :forbidden unless params[:gitlab_qa_formless_login_token] == ENV['GITLAB_QA_FORMLESS_LOGIN_TOKEN']
  end

end
