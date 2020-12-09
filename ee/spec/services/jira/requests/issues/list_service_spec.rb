# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Jira::Requests::Issues::ListService do
  include AfterNextHelpers

  let(:jira_service) { create(:jira_service) }
  let(:params) { {} }

  describe '#execute' do
    let(:service) { described_class.new(jira_service, params) }

    subject { service.execute }

    context 'without jira_service' do
      before do
        jira_service.update!(active: false)
      end

      it 'returns an error response' do
        expect(subject.error?).to be_truthy
        expect(subject.message).to eq('Jira service not configured.')
      end
    end

    context 'when jira_service is nil' do
      let(:jira_service) { nil }

      it 'returns an error response' do
        expect(subject.error?).to be_truthy
        expect(subject.message).to eq('Jira service not configured.')
      end
    end

    context 'with jira_service' do
      context 'when validations and params are ok' do
        let(:jira_service) { create(:jira_service, url: 'https://jira.example.com') }
        let(:response_body) { '' }
        let(:response_headers) { { 'content-type' => '["application/json;charset=UTF-8"]' } }

        before do
          stub_request(:get, /.*jira.example.com\/rest\/api\/2\/search.*/).to_return(status: 200, body: response_body, headers: response_headers)
        end

        context 'when the request to Jira returns an error' do
          before do
            expect_next(JIRA::Client).to receive(:get).and_raise(Timeout::Error)
          end

          it 'returns an error response' do
            expect(subject.error?).to be_truthy
            expect(subject.message).to eq('Jira request error: Timeout::Error')
          end
        end

        context 'when jira runs on a subpath' do
          let(:jira_service) { create(:jira_service, url: 'http://jira.example.com/jira') }

          before do
            stub_request(:get, /.*jira.example.com\/jira\/rest\/api\/2\/search.*/).to_return(status: 200, body: "{}")
          end

          it 'takes the subpath into account' do
            expect(subject.success?).to be_truthy
          end
        end

        context 'when the request does not return any values' do
          let(:response_body) { [].to_json }

          it 'returns a payload with no issues' do
            payload = subject.payload

            expect(subject.success?).to be_truthy
            expect(payload[:issues]).to be_empty
            expect(payload[:is_last]).to be_truthy
          end
        end

        context 'when the request returns values' do
          let(:response_body) do
            {
              total: 375,
              startAt: 0,
              issues: [{ key: 'TST-1' }, { key: 'TST-2' }]
            }.to_json
          end

          it 'returns a payload with jira issues' do
            payload = subject.payload

            expect(subject.success?).to be_truthy
            expect(payload[:issues].map(&:key)).to eq(%w[TST-1 TST-2])
            expect(payload[:is_last]).to be_falsy
          end
        end

        context 'when using pagination parameters' do
          let(:params) { { page: 3, per_page: 20 } }

          it 'honors page and per_page' do
            expect_next(JIRA::Client).to receive(:get).with(include('startAt=40&maxResults=20')).and_return([])

            subject
          end
        end

        context 'without pagination parameters' do
          let(:params) { {} }

          it 'uses the default options' do
            expect_next(JIRA::Client).to receive(:get).with(include('startAt=0&maxResults=100'))

            subject
          end
        end

        it 'requests for default fields' do
          expect_next(JIRA::Client).to receive(:get).with(include("fields=#{described_class::DEFAULT_FIELDS}")).and_return([])

          subject
        end
      end
    end
  end
end
