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
  context 'when the snippet is detected as spam' do
    it 'raises spam flag' do
      allow_next_instance_of(service) do |instance|
        allow(instance).to receive(:spam_check) do |snippet, user, _|
          snippet.spam!
        end
      end

      subject

      expect(mutation_response['spam']).to be true
    end
  end
end
