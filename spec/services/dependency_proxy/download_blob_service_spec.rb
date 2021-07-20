# frozen_string_literal: true
require 'spec_helper'

RSpec.describe DependencyProxy::DownloadBlobService do
  include DependencyProxyHelpers

  let(:image) { 'alpine' }
  let(:token) { Digest::SHA256.hexdigest('123') }
  let(:blob_sha) { Digest::SHA256.hexdigest('ruby:2.7.0') }

  subject(:download_blob) { described_class.new(image, blob_sha, token).execute }

  context 'remote request is successful' do
    before do
      stub_blob_download(image, blob_sha)
    end

    it { expect(subject[:status]).to eq(:success) }
    it { expect(subject[:file]).to be_a(Tempfile) }
    it { expect(subject[:file].size).to eq(6) }

    it 'skips read total timeout' do
      expected_options = { headers: anything, stream_body: true, skip_read_total_timeout: true }
      expect(Gitlab::HTTP).to receive(:perform_request).with(Net::HTTP::Get, anything, expected_options)

      download_blob
    end
  end

  context 'remote request is not found' do
    before do
      stub_blob_download(image, blob_sha, 404)
    end

    it { expect(subject[:status]).to eq(:error) }
    it { expect(subject[:http_status]).to eq(404) }
    it { expect(subject[:message]).to eq('Non-success response code on downloading blob fragment') }
  end

  context 'net timeout exception' do
    before do
      blob_url = DependencyProxy::Registry.blob_url(image, blob_sha)

      stub_full_request(blob_url).to_timeout
    end

    it { expect(subject[:status]).to eq(:error) }
    it { expect(subject[:http_status]).to eq(599) }
    it { expect(subject[:message]).to eq('execution expired') }
  end
end
