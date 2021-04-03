# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::HistoricalStatistics::UpdateService do
  let_it_be(:project) { create(:project) }

  describe '.update_for' do
    let(:mock_service_object) { instance_double(described_class, execute: true) }

    subject(:update_stats) { described_class.update_for(project) }

    before do
      allow(described_class).to receive(:new).with(project).and_return(mock_service_object)
    end

    it 'instantiates an instance of service class and calls execute on it' do
      update_stats

      expect(mock_service_object).to have_received(:execute)
    end
  end

  describe '#execute' do
    subject(:update_stats) { described_class.new(project).execute }

    context 'when the statistic is not empty' do
      before do
        create(:vulnerability_statistic, project: project, low: 2)
      end

      context 'when there is already a record in the database' do
        around do |example|
          travel_to(Date.current) { example.run }
        end

        it 'changes the existing historical statistic entity' do
          historical_statistic = create(:vulnerability_historical_statistic, project: project, letter_grade: 'c')

          expect { update_stats }.to change { historical_statistic.reload.letter_grade }.from('c').to('b')
                                .and change { historical_statistic.reload.low }.to(2)
        end
      end

      context 'when there is no existing record in the database' do
        it 'creates a new record in the database' do
          expect { update_stats }.to change { Vulnerabilities::HistoricalStatistic.count }.by(1)
        end
      end
    end

    context 'when the statistic is empty' do
      it 'does not create any historical statistic entity' do
        expect { update_stats }.not_to change { Vulnerabilities::Statistic.count }
      end
    end
  end
end
