# frozen_string_literal: true

class IssuesChannel < ApplicationCable::Channel
  def subscribed
    issue = Issue.find(params[:id])

    return unless Ability.allowed?(current_user, :read_issue, issue)

    stream_for issue
  end
end
