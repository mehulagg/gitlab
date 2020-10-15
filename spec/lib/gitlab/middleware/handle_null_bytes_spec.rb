# frozen_string_literal: true

require 'spec_helper'
require "rack/test"

RSpec.describe Gitlab::Middleware::HandleNullBytes do

  let(:null_byte) { "\u0000" }
  let(:error_400) { [400, {}, ["Bad Request"]] }
  let(:app) { double(:app) }

  subject { described_class.new(app) }

  before do
    allow(app).to receive(:call) do |args|
      args
    end
  end

  def env_for(params = {})
    Rack::MockRequest.env_for('/', { params: params })
  end

  context 'with null bytes in params' do
    it 'rejects null bytes in a top level param' do
      env = env_for(name: "null#{null_byte}byte")

      expect(subject.call(env)).to eq error_400
    end

    it "responds with 400 BadRequest for hashes with strings" do
      env = env_for(name: { inner_key: "I am #{null_byte} bad" })

      expect(subject.call(env)).to eq error_400
    end

    it "responds with 400 BadRequest for arrays with strings" do
      env = env_for(name: ["I am #{null_byte} bad"])

      expect(subject.call(env)).to eq error_400
    end

    it "responds with 400 BadRequest for arrays containing hashes with string values" do
      env = env_for(name: [
        {
          inner_key: "I am #{null_byte} bad"
        }
      ])

      expect(subject.call(env)).to eq error_400
    end
  end

  context 'without null bytes in params' do
    it "responds with a 200 ok for strings" do
      env = env_for(name: "safe name")

      expect(subject.call(env)).not_to eq error_400
    end

    it "responds with a 200 ok with no params" do
      env = env_for

      expect(subject.call(env)).not_to eq error_400
    end
  end
end
