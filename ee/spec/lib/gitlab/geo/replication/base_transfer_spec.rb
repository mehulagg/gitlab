# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::Replication::BaseTransfer do
  include ::EE::GeoHelpers

  let_it_be(:primary_node) { create(:geo_node, :primary) }
  let_it_be(:secondary_node) { create(:geo_node) }

  describe '#resource_url' do
    subject do
      described_class.new(file_type: 'design_management/design_v432x230',
                          file_id: 1, filename: Tempfile.new, expected_checksum: nil,
                          request_data: nil, resource: nil)
    end

    context 'when file type contains /' do
      it 'returns escaped url' do
        url = subject.resource_url
        expect(url).to include('design_management%2Fdesign_v432x230')
      end
    end
  end

  describe 'HTTP timeout when there are primary connection problems' do
    subject do
      described_class.new(file_type: :avatar, file_id: 1, filename: Tempfile.new,
                          expected_checksum: nil, request_data: nil, resource: nil)
    end

    before do
      stub_current_geo_node(secondary_node)
    end

    it 'sets a timeout when downbloads to local storage' do
      expect(::HTTP).to receive(:timeout)

      subject.download_from_primary
    end

    it 'sets a timeout when streaming to object storage' do
      expect(::HTTP).to receive(:timeout)

      subject.stream_from_primary_to_object_storage
    end
  end

  describe '#can_transfer?' do
    subject do
      described_class.new(file_type: :avatar, file_id: 1, filename: Tempfile.new,
                          expected_checksum: nil, request_data: nil, resource: nil)
    end

    before do
      stub_current_geo_node(secondary_node)
    end

    context 'when not a primary node' do
      it 'returns false when not a secondary node' do
        expect(Gitlab::Geo).to receive(:secondary?) { false }

        expect(subject.can_transfer?).to be_falsey
      end
    end

    context 'when no primary node exists' do
      it 'returns false' do
        expect(Gitlab::Geo).to receive(:primary_node) { nil }

        expect(subject.can_transfer?).to be_falsey
      end
    end

    context 'when destination filename is a directory' do
      it 'returns false' do
        subject = described_class.new(file_type: :avatar, file_id: 1, filename: Dir::Tmpname.tmpdir,
                                      expected_checksum: nil, request_data: nil, resource: nil)

        expect(subject.can_transfer?).to be_falsey
      end
    end

    context 'when no filename is informed' do
      it 'returns true' do
        subject = described_class.new(file_type: :avatar, file_id: 1, expected_checksum: nil,
                                      request_data: nil, resource: nil)

        expect(subject.can_transfer?).to be_truthy
      end
    end

    it 'returns true when is a secondary, a primary exists and filename doesnt point to an existing directory' do
      expect(subject.can_transfer?).to be_truthy
    end
  end

  describe '#stream_from_primary_to_object_storage' do
    let_it_be(:lfs_object) { create(:lfs_object, :with_file, :correct_oid) }

    let(:auth_headers) { { 'Authorization' => 'Bearer 12345' } }
    let(:download_link) { 'http://download.link' }

    subject do
      Gitlab::Geo::Replication::LfsTransfer.new(lfs_object)
    end

    before do
      stub_current_geo_node(secondary_node)
    end

    it 'downloads file successfully' do
      allow_next_instance_of(Gitlab::Geo::TransferRequest) do |request|
        allow(request).to receive(:headers).and_return(auth_headers)
      end

      stub_request(:get, primary_node.geo_transfers_url(:lfs, lfs_object.id.to_s))
        .to_return(status: 302, headers: { 'Location' => download_link })

      # This stub acts as assertion that auth headers are not present,
      # otherwise we would get 500 error
      stub_request(:get, download_link)
        .with(headers: auth_headers)
        .to_return(status: 500)

      stub_request(:get, download_link)
        .to_return(status: 200)

      expect(subject.stream_from_primary_to_object_storage.success).to be_truthy
    end
  end
end
