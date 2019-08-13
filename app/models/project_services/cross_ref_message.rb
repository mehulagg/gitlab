# frozen_string_literal: true

class CrossRefMessage
  private

  attr_accessor :user_name, :user_url, :entity_name, :entity_url, :entity_title, :project_name

  public

  def initialize(data)
    @user_name = data[:user][:name]
    @user_url = data[:user][:url]
    @entity_name = data[:entity][:name]
    @entity_url = data[:entity][:url]
    @entity_title = data[:entity][:title]
    @project_name = data[:project][:name]
  end

  def markdown_message
    "[#{user_name}](#{user_url}) mentioned this issue in [a #{entity_name} of #{project_name}](#{entity_url}):\n'#{entity_title.chomp}'"
  end

  def jira_message
    "[#{user_name}|#{user_url}] mentioned this issue in [a #{entity_name} of #{project_name}|#{entity_url}]:\n'#{entity_title.chomp}'"
  end
end
