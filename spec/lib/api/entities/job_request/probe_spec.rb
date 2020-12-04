# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::API::Entities::JobRequest::Probe do
  let(:exec_probe) { { command: ['cmd', '-c'] } }
  let(:http_get_probe) { { scheme: 'https', port: 8080, path: '/healthz', headers: ['x-custom: value'] } }
  let(:tcp_probe) { { port: 80 } }
  let(:probe_config) { double(exec: exec_probe, http_get: http_get_probe, tcp: tcp_probe,
                        initial_delay: 1, period: 1, timeout: 1, retries: 2) }
  let(:entity) { described_class.new(probe_config) }

  subject { entity.as_json }

  it 'returns the exec probe' do
    expect(subject[:exec]).to eq exec_probe
  end

  it 'returns the http_get probe' do
    expect(subject[:http_get]).to eq http_get_probe
  end

  it 'returns the tcp probe' do
    expect(subject[:tcp]).to eq tcp_probe
  end

  it 'returns the initial delay' do
    expect(subject[:initial_delay]).to eq 1
  end

  it 'returns the period' do
    expect(subject[:period]).to eq 1
  end

  it 'returns the timeout' do
    expect(subject[:timeout]).to eq 1
  end

  it 'returns the retries' do
    expect(subject[:retries]).to eq 2
  end
end
