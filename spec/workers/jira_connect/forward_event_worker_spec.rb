# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::ForwardEventWorker do
  describe '#perform' do
    let!(:jira_connect_installation) { create(:jira_connect_installation, instance_url: 'http://example.com') }
    let(:auth_header) { 'some auth string' }

    subject { described_class.new.perform(jira_connect_installation.id, auth_header) }

    it 'forwards the event including the auth header and deletes the installation' do
      stub_request(:post, "http://example.com/")

      expect { subject }.to change(JiraConnectInstallation, :count).by(-1)

      expect(WebMock).to have_requested(:post, jira_connect_installation.instance_url).with(headers: { 'Authorizationh' => auth_header })
    end

    context 'when installation does not have an instance_url' do
      let!(:jira_connect_installation) { create(:jira_connect_installation) }

      it 'forwards the event including the auth header' do
        expect { subject }.to change(JiraConnectInstallation, :count).by(-1)

        expect(WebMock).not_to have_requested(:post, '*')
      end
    end

    context 'when it fails to forward the event' do
      it 'still deletes the installation' do
        allow(Gitlab::HTTP).to receive(:post).and_raise(StandardError)

        expect { subject }.to raise_error(StandardError).and change(JiraConnectInstallation, :count).by(-1)
      end
    end
  end
end
