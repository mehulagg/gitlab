# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SyncSeatLinkRequestWorker, type: :worker do
  describe '#perform' do
    subject do
      described_class.new.perform('2020-01-01T01:20:12+02:00', '123', 5, 4)
    end

    let(:seat_link_url) { [EE::SUBSCRIPTIONS_URL, '/api/v1/seat_links'].join }

    it 'makes an HTTP POST request with passed params' do
      stub_request(:post, seat_link_url).to_return(status: 200)

      subject

      expect(WebMock).to have_requested(:post, seat_link_url).with(
        headers: { 'Content-Type' => 'application/json' },
        body: {
          timestamp: '2019-12-31T23:20:12Z',
          date: '2019-12-31',
          license_key: '123',
          max_historical_user_count: 5,
          active_users: 4
        }.to_json
      )
    end

    context 'when response contains a license' do
      let(:license_key) { build(:gitlab_license).export }
      let(:body) { { success: true, license: license_key }.to_json }

      before do
        stub_request(:post, seat_link_url).to_return(
          status: 200,
          body: body,
          headers: { content_type: 'application/json' }
        )
      end

      it 'persists returned license' do
        expect { subject }.to change(License, :count).by(1)
        expect(License.last).to have_attributes(
          data: license_key,
          cloud: true
        )
      end

      context 'when persisting fails' do
        let(:license_key) { 'invalid-key' }

        it 'logs error' do
          expect(Gitlab::ErrorTracking).to receive(:track_and_raise_for_dev_exception).and_call_original

          expect { subject }.to raise_error
        end
      end
    end

    context 'with old date format string' do
      subject do
        described_class.new.perform('2020-01-01', '123', 5, 4)
      end

      it 'makes an HTTP POST request with passed params' do
        stub_request(:post, seat_link_url).to_return(status: 200)

        subject

        expect(WebMock).to have_requested(:post, seat_link_url).with(
          headers: { 'Content-Type' => 'application/json' },
          body: {
            timestamp: '2020-01-01T00:00:00Z',
            date: '2020-01-01',
            license_key: '123',
            max_historical_user_count: 5,
            active_users: 4
          }.to_json
        )
      end
    end

    shared_examples 'unsuccessful request' do
      context 'when the request is not successful' do
        before do
          stub_request(:post, seat_link_url)
            .to_return(status: 400, body: '{"success":false,"error":"Bad Request"}')
        end

        it 'raises an error with the expected message' do
          expect { subject }.to raise_error(
            described_class::RequestError,
            'Seat Link request failed! Code:400 Body:{"success":false,"error":"Bad Request"}'
          )
        end
      end
    end

    it_behaves_like 'unsuccessful request'
  end
end
