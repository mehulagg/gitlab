# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::Licenses::UsageExportsController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'GET show' do
    subject { get :show, format: :csv }

    context 'with no current license' do
      before do
        allow(License).to receive(:current).and_return(nil)
        allow(HistoricalUserData::CsvService).to receive(:new).and_call_original
      end

      it 'redirects the user' do
        subject

        expect(response).to have_gitlab_http_status(:redirect)
      end

      it 'does not attempt to create the CSV' do
        subject

        expect(HistoricalUserData::CsvService).not_to have_received(:new)
      end
    end

    context 'with a current license' do
      let(:csv_data) do
        <<~CSV
          Date,Active User Count
          2020-08-26,1
          2020-08-27,2
        CSV
      end

      let(:csv_service) { instance_double(HistoricalUserData::CsvService, generate: csv_data) }
      let(:historical_data_relation) { :historical_data_relation }

      before do
        license = build(:license)
        allow(License).to receive(:current).and_return(license)
        allow(license).to receive(:historical_data).and_return(historical_data_relation)
        allow(HistoricalUserData::CsvService).to receive(:new).with(historical_data_relation).and_return(csv_service)
      end

      it 'returns a csv file in response' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      end

      it 'returns the expected response body' do
        subject

        expect(CSV.parse(response.body)).to eq([
          ['Date', 'Active User Count'],
          %w[2020-08-26 1],
          %w[2020-08-27 2]
        ])
      end
    end
  end
end
