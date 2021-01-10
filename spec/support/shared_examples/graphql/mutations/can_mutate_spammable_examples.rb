# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'spam flag is present' do
  specify :aggregate_failures do
    subject

    expect(mutation_response).to have_key('spam')
    expect(mutation_response['spam']).to be_falsey
  end
end

RSpec.shared_examples 'can raise spam flag' do
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

          # TODO: Is it appropriate for these the tests of the mutation to be coupled to the
          #   implementation of the service, and mocking logic which lives within the service?
          {
            spam: true,
            needs_recaptcha_response: true,
            spam_log_id: 1,
            recaptcha_site_key: 'fake-recaptcha-site-key'
          }
        end
      end

      subject

      expect(mutation_response['spam']).to be true
      expect(mutation_response['errors']).to include("Your snippet has been recognized as spam and has been discarded.")
    end
  end

  context 'when :snippet_spam flag is disabled' do
    # TODO: Move this to the service tests, the check now lives there
    before do
      stub_feature_flags(snippet_spam: false)
    end

    it 'request parameter is not passed to the service' do
      expect(service).not_to receive(:spam_check)

      subject
    end
  end
end
