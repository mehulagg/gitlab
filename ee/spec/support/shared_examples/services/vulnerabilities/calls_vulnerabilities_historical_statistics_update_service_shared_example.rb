# frozen_string_literal: true

RSpec.shared_examples 'calls Vulnerabilities::HistoricalStatistics::UpdateService' do
  before do
    allow(Vulnerabilities::HistoricalStatistics::UpdateService).to receive(:update_for)
  end

  it 'calls the service class' do
    subject

    expect(Vulnerabilities::HistoricalStatistics::UpdateService).to have_received(:update_for)
  end
end
