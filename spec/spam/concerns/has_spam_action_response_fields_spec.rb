# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spam::Concerns::HasSpamActionResponseFields do
  subject do
    clazz = Class.new
    clazz.include described_class
    clazz.new
  end

  describe '#with_spam_action_response_fields' do
    let(:spam_log) { double(:spam_log, id: 1) }
    let(:spammable) { double(:spammable, spam?: true, render_recaptcha?: true, spam_log: spam_log) }

    before do
      allow(Gitlab::CurrentSettings).to receive(:recaptcha_site_key) { 'abc123' }
    end

    it 'merges in spam action fields from spammable' do
      result = subject.send(:with_spam_action_response_fields, spammable) do
        { other_field: true }
      end
      expect(result)
        .to eq({
                 spam: true,
                 needs_captcha_response: true,
                 spam_log_id: 1,
                 captcha_site_key: 'abc123',
                 other_field: true
               })
    end
  end
end
