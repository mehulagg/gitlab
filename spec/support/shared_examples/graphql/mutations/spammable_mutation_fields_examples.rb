# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'spammable fields are present' do
  specify :aggregate_failures do
    subject

    expect(mutation_response).to have_key('spam')
    expect(mutation_response['spam']).to be_falsey
    expect(mutation_response).to have_key('needsRecaptcha')
    expect(mutation_response['needsRecaptcha']).to be_falsey
    expect(mutation_response).to have_key('spamLogId')
    expect(mutation_response['spamLogId']).to be_falsey
  end
end

RSpec.shared_examples 'can raise spam flags' do
  it 'spam parameters are passed to the service' do
    args = [anything, anything, hash_including(api: true, request: instance_of(ActionDispatch::Request))]
    expect(service).to receive(:new).with(*args).and_call_original

    subject
  end

  context 'when the snippet is detected as spam' do
    it 'raises spam flag' do
      allow_next_instance_of(service) do |instance|
        allow(instance).to receive(:spam_check) do |snippet, user, _|
          snippet.spam!
        end
      end

      subject

      expect(mutation_response['spam']).to be true
      expect(mutation_response['errors']).to include("Your snippet has been recognized as spam and has been discarded.")
    end
  end

  context 'when :snippet_spam flag is disabled' do
    before do
      stub_feature_flags(snippet_spam: false)
    end

    it 'request parameter is not passed to the service' do
      expect(service).to receive(:new)
        .with(anything, anything, hash_not_including(request: instance_of(ActionDispatch::Request)))
        .and_call_original

      subject
    end
  end

  context 'when the snippet is detected as needs recaptcha' do
    before do
      stub_application_setting(recaptcha_enabled: recaptcha_setting)

      allow_next_instance_of(service) do |instance|
        allow(instance).to receive(:spam_check) do |snippet, user, _|
          snippet.needs_recaptcha!
          snippet.spam_log = spam_log
        end
      end

      subject
    end

    context 'Recaptcha is not enabled' do
      let(:recaptcha_setting) { false }

      it 'does not raise needs_recaptcha flag' do
        expect(mutation_response['needsRecaptcha']).to be false
      end
    end

    context 'Recaptcha is enabled' do
      let(:recaptcha_setting) { true }

      it 'raises needs_recaptcha flag' do
        expect(mutation_response['needsRecaptcha']).to be true
        expect(mutation_response['errors']).to eq(["Your snippet has been recognized as spam. Please, change the content or solve the reCAPTCHA to proceed."])
      end

      it 'includes spamLogId' do
        expect(mutation_response['spamLogId']).to eq spam_log.id
      end
    end
  end
end

RSpec.shared_examples 'spammable fields with validation errors' do
  it 'needs_recaptcha flag is not raised' do
    stub_application_setting(recaptcha_enabled: true)

    allow_next_instance_of(service) do |instance|
      allow(instance).to receive(:spam_check) do |snippet, user, _|
        snippet.needs_recaptcha!
        snippet.spam_log = spam_log
      end
    end

    subject

    expect(mutation_response['needsRecaptcha']).to be false
    expect(mutation_response['errors']).to eq(["Title can't be blank", "Your snippet has been recognized as spam. Please, change the content or solve the reCAPTCHA to proceed."])
  end
end
