# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::SlackApplicationInstallService do
  let!(:user) { create(:user) }
  let!(:project) { create(:project) }

  def service(params = {})
    Projects::SlackApplicationInstallService.new(project, user, params)
  end

  def stub_slack_response_with(response)
    expect_next_instance_of(Projects::SlackApplicationInstallService) do |instance|
      expect(instance).to receive(:exchange_slack_token).and_return(response.stringify_keys)
    end
  end

  def expect_slack_integration_is_created(project)
    integration = SlackIntegration.find_by(service_id: project.gitlab_slack_application_integration.id)
    expect(integration).to be_present
  end

  def expect_chat_name_is_created(project)
    chat_name = ChatName.find_by(service_id: project.gitlab_slack_application_integration.id)
    expect(chat_name).to be_present
  end

  it 'returns error result' do
    stub_slack_response_with(ok: false, error: 'something is wrong')

    result = service.execute

    expect(result).to eq(message: 'Slack: something is wrong', status: :error)
  end

  it 'returns success result and creates all the needed records' do
    stub_slack_response_with(
      ok: true,
      access_token: 'XXXX',
      user_id: 'U12345',
      team_id: 'T1265',
      team_name: 'super-team'
    )

    result = service.execute

    expect(result).to eq(status: :success)
    expect_slack_integration_is_created(project)
    expect_chat_name_is_created(project)
  end
end
