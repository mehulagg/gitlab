# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnectInstallations::DestroyService do
  let(:installation) { create(:jira_connect_installation) }
  let(:qsh) { Atlassian::Jwt.create_query_string_hash('https://gitlab.test/events/uninstalled', 'POST', 'https://gitlab.test') }
  let(:auth_token) do
    Atlassian::Jwt.encode({ iss: installation.client_key, qsh: qsh }, installation.shared_secret)
  end
  let(:auth_header) { "JWT #{auth_token}" }

  subject { described_class.new(installation, auth_header).execute }

  it { is_expected.to be_truthy }

  it 'deletes the installation' do
    expect { subject }.to change { JiraConnectInstallation.count }.by(-1)
  end

  context 'and the installation has an instance_url set' do
    let!(:installation) { create(:jira_connect_installation, instance_url: 'http://example.com') }

    it { is_expected.to be_truthy }

    it 'schedules a ForwardEventWorker background job and keeps the installation' do
      expect(JiraConnect::ForwardEventWorker).to receive(:perform_async).with(installation.id, auth_header)

      expect { subject }.not_to change(JiraConnectInstallation, :count)
    end
  end
end
