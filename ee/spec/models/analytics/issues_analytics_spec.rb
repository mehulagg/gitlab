# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::IssuesAnalytics do
  subject { described_class.new(issues: project.issues) }

  let_it_be(:project) { create(:project, skip_disk_validation: true) }

  describe '#monthly_counters' do
    let_it_be(:today) { Date.today }
    let_it_be(:seed_data) do
      (0..13).to_a.each_with_object({}) do |month_offset, result|
        month = today - month_offset.months

        result[month.strftime(described_class::DATE_FORMAT)] = {
          created: rand(2..4),
          closed: rand(2)
        }
      end
    end

    let_it_be(:seeded_issues) do
      seed_data.map do |month, seed_counters|
        month = Date.parse("#{month}-01")
        issues = []
        seed_counters[:closed].times do
          issues << create(:issue, :closed, project: project, created_at: month + 1.day, closed_at: month + 2.days)
        end

        (seed_counters[:created] - seed_counters[:closed]).times do
          issues << create(:issue, :opened, project: project, created_at: month + 1.day)
        end

        issues
      end.flatten
    end

    def accumulated_open_for_seeds(month)
      seed_data.map do |seed_month, data|
        data[:created] - data[:closed] if seed_month <= month
      end.compact.sum
    end

    context 'without months_back specified' do
      let(:expected_counters) do
        (0..12).to_a.each_with_object({}) do |month_offset, result|
          month = (today - month_offset.months).strftime(described_class::DATE_FORMAT)

          result[month] = seed_data[month].merge(accumulated_open: accumulated_open_for_seeds(month))
        end
      end

      it 'returns data for 12 months' do
        expect(subject.monthly_counters).to match(expected_counters)
      end
    end

    context 'with months_back set to 3' do
      subject { described_class.new(issues: project.issues, months_back: 3) }

      let(:expected_counters) do
        (0..2).to_a.each_with_object({}) do |month_offset, result|
          month = (today - month_offset.months).strftime(described_class::DATE_FORMAT)

          result[month] = seed_data[month].merge(accumulated_open: accumulated_open_for_seeds(month))
        end
      end

      it 'returns data for 3 months' do
        expect(subject.monthly_counters).to match(expected_counters)
      end
    end
  end
end
