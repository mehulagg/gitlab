# frozen_string_literal: true

require 'spec_helper'


RSpec.describe Gitlab::SpamcheckClient::Client do
  include_context 'includes Spam constants'

  let(:endpoint){'http://grpc.test.url'}
  let(:user) {create(:user)}
  let(:verdict_value) { Spamcheck::SpamVerdict::Verdict::ALLOW }
  let(:error_value) { "" }

  let(:response) do
    verdict = Spamcheck::SpamVerdict.new
    binding.pry
    verdict.verdict = verdict_value
    verdict.error = error_value
    verdict
  end

  #let(:stub) {Spamcheck::SpamcheckService::Stub.new(endpoint_url: endpoint)}

  subject { described_class.new(endpoint_url: endpoint) }

  context '#issue_spam?' do

    before do
      allow_next_instance_of(::Spamcheck::SpamcheckService::Stub) do |instance|
        allow(instance).to receive(:check_for_spam_issue).and_return(response)
      end
    end

    it 'returns ALLOW' do
      issue = create(:issue)

      expect(subject.issue_spam?(spam_issue: issue, user: user)).to eq([ALLOW, ""])
    end
  end
end
