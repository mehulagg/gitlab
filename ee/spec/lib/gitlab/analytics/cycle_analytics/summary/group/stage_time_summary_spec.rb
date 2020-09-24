# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::Analytics::CycleAnalytics::Summary::Group::StageTimeSummary do
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:project_2) { create(:project, :repository, namespace: group) }
  let(:from) { 1.day.ago }
  let(:to) { nil }
  let(:user) { create(:user, :admin) }

  subject { described_class.new(group, options: { from: from, to: to, current_user: user }).data }

  around do |example|
    Timecop.freeze { example.run }
  end

  describe '#lead_time' do
    context 'with `from` date' do
      let(:from) { 6.days.ago }

      before do
        create(:closed_issue, project: project, created_at: 1.day.ago, closed_at: Time.now)
        create(:closed_issue, project: project, created_at: 2.days.ago, closed_at: Time.now)
        create(:closed_issue, project: project_2, created_at: 4.days.ago, closed_at: Time.now)
      end

      it 'finds the lead time of issues created after it' do
        expect(subject.first[:value]).to eq('2.0')
      end

      context 'with subgroups' do
        let(:subgroup) { create(:group, parent: group) }
        let(:project_3) { create(:project, namespace: subgroup) }

        before do
          create(:closed_issue, created_at: 3.days.ago, closed_at: Time.now, project: project_3)
          create(:closed_issue, created_at: 5.days.ago, closed_at: Time.now, project: project_3)
        end

        it 'finds the lead time of issues from them' do
          expect(subject.first[:value]).to eq('3.0')
        end
      end

      context 'with projects specified in options' do
        before do
          create(:closed_issue, created_at: 3.days.ago, closed_at: Time.now, project: create(:project, namespace: group))
        end

        subject { described_class.new(group, options: { from: from, current_user: user, projects: [project.id, project_2.id] }).data }

        it 'finds the lead time of issues from those projects' do
          # Median of 1, 2, 4, not including new issue
          expect(subject.first[:value]).to eq('2.0')
        end
      end

      context 'when `from` and `to` parameters are provided' do
        let(:from) { 3.days.ago }
        let(:to) { Time.now }

        it 'finds the lead time of issues from 3 days ago' do
          expect(subject.first[:value]).to eq('1.5')
        end
      end
    end

    context 'with other projects' do
      let(:from) { 4.days.ago }

      before do
        create(:closed_issue, created_at: 1.day.ago, closed_at: Time.now, project: create(:project, namespace: create(:group)))
        create(:closed_issue, created_at: 2.days.ago, closed_at: Time.now,  project: project)
        create(:closed_issue, created_at: 3.days.ago, closed_at: Time.now,  project: project_2)
      end

      it 'does not find the lead time of issues from them' do
        # Median of  2, 3, not including first issue
        expect(subject.first[:value]).to eq('2.5')
      end
    end
  end
end
