# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpamCheckMethods do
  let(:klass) do
    Class.new do
      include SpamCheckMethods
      attr_reader :params

      def initialize(params)
        @params = params
      end
    end
  end

  let(:request) { double(:request) }
  let(:api) { double(:api) }
  let(:recaptcha_verified) { double(:recaptcha_verified) }
  let(:spam_log_id) { double(:spam_log_id) }
  let(:recaptcha_response) { double(:recaptcha_response) }
  let(:params) do
    {
      request: request,
      api: api,
      recaptcha_verified: recaptcha_verified,
      spam_log_id: spam_log_id,
      recaptcha_response: recaptcha_response
    }
  end

  subject { klass.new(params) }

  describe '#request' do
    it 'has an attr_reader set to the request from the params' do
      subject.filter_spam_check_params

      expect(subject.request).to eq(request)
    end
  end

  describe '#filter_spam_check_params' do
    it 'deletes params and assigns them to instance variables' do
      subject.filter_spam_check_params

      expect(subject.request).to eq(request)
      expect(subject.instance_variable_get(:@api)).to eq(api)
      expect(subject.instance_variable_get(:@recaptcha_verified)).to eq(recaptcha_verified)
      expect(subject.instance_variable_get(:@spam_log_id)).to eq(spam_log_id)

      expect(params).to be_empty
    end
  end

  describe '#spam_check' do
    let(:spammable) { double(:spammable) }
    let(:user) { double(:user) }

    context 'without an action' do
      it 'raises an error if an action is not provided' do
        expect do
          subject.spam_check(spammable, user, action: nil)
        end.to raise_error(ArgumentError, /provide an action/)
      end
    end

    context 'with an action' do
      let(:action) { :create }
      let(:spam_log) { double(:spam_log, id: 1) }

      before do
        allow(spammable).to receive(:spam?) { true }
        allow(spammable).to receive(:spam_log) { spam_log }
        allow(subject).to receive(:render_recaptcha?).with(spammable) { true }
      end

      it 'executes spam action service' do
        new_args = {
          spammable: spammable,
          request: request,
          user: user,
          context: { action: action }
        }
        expect_next_instance_of(Spam::SpamActionService, **new_args) do |service|
          expect(service).to receive(:execute).with(
            api: api,
            recaptcha_verified: recaptcha_verified,
            spam_log_id: spam_log_id
          )
        end

        subject.filter_spam_check_params
        result = subject.spam_check(spammable, user, action: action)

        expect(result).to eq({
                               spam: true,
                               needs_recaptcha_response: true,
                               spam_log_id: 1,
                               recaptcha_site_key: Gitlab::CurrentSettings.recaptcha_site_key
                             })
      end
    end
  end
end
