# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Spamcheck::Client do
  include_context 'includes Spam constants'

  let(:endpoint) { 'grpc://grpc.test.url' }
  let(:user) { create(:user) }
  let(:verdict_value) { nil }
  let(:error_value) { "" }
  let(:issue) { create(:issue) }

  let(:response) do
    verdict = ::Spamcheck::SpamVerdict.new
    verdict.verdict = verdict_value
    verdict.error = error_value
    verdict
  end

  subject { described_class.new(endpoint_url: endpoint).issue_spam?(spam_issue: issue, user: user) }

  describe '#issue_spam?' do
    before do
      allow_next_instance_of(::Spamcheck::SpamcheckService::Stub) do |instance|
        allow(instance).to receive(:check_for_spam_issue).and_return(response)
      end
    end

    using RSpec::Parameterized::TableSyntax

    where(:verdict, :expected) do
      ::Spamcheck::SpamVerdict::Verdict::ALLOW                | Spam::SpamConstants::ALLOW
      ::Spamcheck::SpamVerdict::Verdict::CONDITIONAL_ALLOW    | Spam::SpamConstants::CONDITIONAL_ALLOW
      ::Spamcheck::SpamVerdict::Verdict::DISALLOW             | Spam::SpamConstants::DISALLOW
      ::Spamcheck::SpamVerdict::Verdict::BLOCK                | Spam::SpamConstants::BLOCK_USER
    end

    with_them do
      let(:verdict_value) { verdict }

      it "returns expected spam constant" do
        expect(subject).to eq([expected, ""])
      end
    end
  end
end
