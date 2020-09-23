# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::ResponseStore do
  let(:raw_response) { '<xml></xml>' }
  let(:session_id) { '123-456-789' }

  subject { described_class.new(session_id) }

  describe '#set_raw' do
    it 'stores values in Redis' do
      subject.set_raw(raw_response)

      stored_value = Gitlab::Redis::SharedState.with do |redis|
        redis.get("last_saml_debug_response:#{session_id}")
      end

      expect(stored_value).to eq raw_response
    end

    it 'sets a redis expiry time' do
      Gitlab::Redis::SharedState.with do |redis|
        expect(redis).to receive(:set).with(anything, anything, ex: 5.minutes)
      end

      subject.set_raw(raw_response)
    end
  end

  describe '#get_raw' do
    it 'retrives a value set by set_response' do
      subject.set_raw(raw_response)

      expect(subject.get_raw).to eq raw_response
    end

    it 'prevents memory bloat by deleting the value' do
      subject.set_raw(raw_response)
      subject.get_raw

      expect(subject.get_raw).to be_nil
    end
  end
end
