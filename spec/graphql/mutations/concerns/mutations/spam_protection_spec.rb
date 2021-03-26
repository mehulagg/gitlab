# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::SpamProtection do
  let(:mutation_class) do
    Class.new(Mutations::BaseMutation) do
      include Mutations::SpamProtection
    end
  end

  let(:request) { double(:request) }
  let(:query) { double(:query, schema: GitlabSchema) }
  let(:context) { GraphQL::Query::Context.new(query: query, object: nil, values: { request: request }) }

  subject(:mutation) { mutation_class.new(object: nil, context: context, field: nil) }

  describe '#additional_spam_params' do
    it 'returns additional spam-related params' do
      expect(subject.send(:additional_spam_params)).to eq({ api: true, request: request })
    end
  end

  describe '#check_spam_action_response!' do
    def check_spam
      spam_log = double(:spam_log, id: 1)
      spammable = double(:spammable, spam?: spam, render_recaptcha?: render_captcha, spam_log: spam_log)
      subject.send(:check_spam_action_response!, spammable)
    end

    context 'when the object is not spam and no CAPTCHA is required' do
      let(:spam) { false }
      let(:render_captcha) { false }

      it 'does not raise' do
        expect { check_spam }.not_to raise_error
      end
    end

    context 'when the object is spam and no CAPTCHA is available' do
      let(:spam) { true }
      let(:render_captcha) { false }

      it 'raises SpamDisallowedError' do
        expect { check_spam }.to raise_error(described_class::SpamDisallowedError)
      end
    end

    context 'when the object is spam and a CAPTCHA is required' do
      let(:spam) { true }
      let(:render_captcha) { true }

      it 'raises SpamDisallowedError' do
        expect { check_spam }.to raise_error(described_class::SpamDisallowedError)
      end
    end

    context 'when the object is not spam and a CAPTCHA is required' do
      let(:spam) { false }
      let(:render_captcha) { true }

      it 'raises NeedsCaptchaResponseError' do
        expect { check_spam }.to raise_error(described_class::NeedsCaptchaResponseError)
      end
    end
  end
end
