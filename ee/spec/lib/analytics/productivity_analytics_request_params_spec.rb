# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::ProductivityAnalyticsRequestParams do
  let(:params) do
    {
      author_username: 'user',
      label_name: %w[label1 label2],
      milestone_title: 'user',
      merged_after: 5.days.ago.to_time,
      merged_before: Date.today.to_time,
      group: Group.new
    }
  end

  subject { described_class.new(params) }

  describe 'validations' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    describe '`merged_at` params' do
      context 'when `merged_before` is earlier than `merged_after`' do
        before do
          params[:merged_after] = Date.today.to_time
          params[:merged_before] = 5.days.ago.to_time
        end

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:merged_before]).not_to be_empty
        end
      end

      context 'when `merged_after` is earlier than `productivity_analytics_start_date`' do
        before do
          params[:merged_after] = 5.days.ago.to_time

          allow(ApplicationSetting)
            .to receive(:current)
            .and_return(ApplicationSetting.build_from_defaults(productivity_analytics_start_date: Date.today.to_time))
        end

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:merged_after]).not_to be_empty
        end
      end

      context 'when `merged_before` is earlier than `productivity_analytics_start_date`' do
        before do
          params[:merged_before] = 5.days.ago.to_time

          allow(ApplicationSetting)
            .to receive(:current)
            .and_return(ApplicationSetting.build_from_defaults(productivity_analytics_start_date: Date.today.to_time))
        end

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors.messages[:merged_before]).not_to be_empty
        end
      end
    end
  end

  describe 'default values' do
    around do |example|
      freeze_time { example.run }
    end

    describe '`merged_before`' do
      it 'defaults to today date' do
        expect(described_class.new.merged_before).to eq(Date.today.at_end_of_day)
      end
    end

    describe '`merged_after`' do
      context 'when `productivity_analytics_start_date` is within the last 30 days' do
        before do
          allow(ApplicationSetting)
            .to receive(:current)
            .and_return(ApplicationSetting.build_from_defaults(productivity_analytics_start_date: 15.days.ago.to_time))
        end

        it 'defaults to `productivity_analytics_start_date`' do
          expect(described_class.new.merged_after).to eq(ApplicationSetting.current.productivity_analytics_start_date.beginning_of_day)
        end
      end

      context 'when `productivity_analytics_start_date` older than 30 days' do
        before do
          allow(ApplicationSetting)
            .to receive(:current)
            .and_return(ApplicationSetting.build_from_defaults(productivity_analytics_start_date: 45.days.ago.to_time))
        end

        it 'defaults to 30 days ago' do
          expect(described_class.new.merged_after).to eq(30.days.ago.to_time.utc.beginning_of_day)
        end
      end
    end
  end
end
