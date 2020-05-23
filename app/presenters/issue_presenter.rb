# frozen_string_literal: true

class IssuePresenter < Gitlab::View::Presenter::Delegated
  presents :issue

  def web_url
    url_builder.build(issue)
  end

  def issue_path
    url_builder.build(issue, only_path: true)
  end

  def subscribed?
    issue.subscribed?(current_user, issue.project)
  end
end
