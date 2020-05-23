# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::CycleAnalytics::StageSummary do
  let(:project) { create(:project, :repository) }
  let(:options) { { from: 1.day.ago, current_user: user } }
  let(:user) { create(:user, :admin) }

  before do
    project.add_maintainer(user)
  end

  let(:stage_summary) { described_class.new(project, options).data }

  describe "#new_issues" do
    subject { stage_summary.first[:value] }

    it "finds the number of issues created after the 'from date'" do
      Timecop.freeze(5.days.ago) { create(:issue, project: project) }
      Timecop.freeze(5.days.from_now) { create(:issue, project: project) }

      expect(subject).to eq('1')
    end

    it "doesn't find issues from other projects" do
      Timecop.freeze(5.days.from_now) { create(:issue, project: create(:project)) }

      expect(subject).to eq('-')
    end

    context 'when `to` parameter is given' do
      before do
        Timecop.freeze(5.days.ago) { create(:issue, project: project) }
        Timecop.freeze(5.days.from_now) { create(:issue, project: project) }
      end

      it "doesn't find any record" do
        options[:to] = Time.now

        expect(subject).to eq('-')
      end

      it "finds records created between `from` and `to` range" do
        options[:from] = 10.days.ago
        options[:to] = 10.days.from_now

        expect(subject).to eq('2')
      end
    end
  end

  describe "#commits" do
    subject { stage_summary.second[:value] }

    it "finds the number of commits created after the 'from date'" do
      Timecop.freeze(5.days.ago) { create_commit("Test message", project, user, 'master') }
      Timecop.freeze(5.days.from_now) { create_commit("Test message", project, user, 'master') }

      expect(subject).to eq('1')
    end

    it "doesn't find commits from other projects" do
      Timecop.freeze(5.days.from_now) { create_commit("Test message", create(:project, :repository), user, 'master') }

      expect(subject).to eq('-')
    end

    it "finds a large (> 100) number of commits if present" do
      Timecop.freeze(5.days.from_now) { create_commit("Test message", project, user, 'master', count: 100) }

      expect(subject).to eq('100')
    end

    context 'when `to` parameter is given' do
      before do
        Timecop.freeze(5.days.ago) { create_commit("Test message", project, user, 'master') }
        Timecop.freeze(5.days.from_now) { create_commit("Test message", project, user, 'master') }
      end

      it "doesn't find any record" do
        options[:to] = Time.now

        expect(subject).to eq('-')
      end

      it "finds records created between `from` and `to` range" do
        options[:from] = 10.days.ago
        options[:to] = 10.days.from_now

        expect(subject).to eq('2')
      end
    end

    context 'when a guest user is signed in' do
      let(:guest_user) { create(:user) }

      before do
        project.add_guest(guest_user)
        options.merge!({ current_user: guest_user })
      end

      it 'does not include commit stats' do
        data = described_class.new(project, options).data
        expect(includes_commits?(data)).to be_falsy
      end

      def includes_commits?(data)
        data.any? { |h| h["title"] == 'Commits' }
      end
    end
  end

  describe "#deploys" do
    subject { stage_summary.third[:value] }

    it "finds the number of deploys made created after the 'from date'" do
      Timecop.freeze(5.days.ago) { create(:deployment, :success, project: project) }
      Timecop.freeze(5.days.from_now) { create(:deployment, :success, project: project) }

      expect(subject).to eq('1')
    end

    it "doesn't find commits from other projects" do
      Timecop.freeze(5.days.from_now) do
        create(:deployment, :success, project: create(:project, :repository))
      end

      expect(subject).to eq('-')
    end

    context 'when `to` parameter is given' do
      before do
        Timecop.freeze(5.days.ago) { create(:deployment, :success, project: project) }
        Timecop.freeze(5.days.from_now) { create(:deployment, :success, project: project) }
      end

      it "doesn't find any record" do
        options[:to] = Time.now

        expect(subject).to eq('-')
      end

      it "finds records created between `from` and `to` range" do
        options[:from] = 10.days.ago
        options[:to] = 10.days.from_now

        expect(subject).to eq('2')
      end
    end
  end

  describe '#deployment_frequency' do
    subject { stage_summary.fourth[:value] }

    it 'includes the unit: `per day`' do
      expect(stage_summary.fourth[:unit]).to eq _('per day')
    end

    before do
      Timecop.freeze(5.days.ago) { create(:deployment, :success, project: project) }
    end

    it 'returns 0.0 when there were deploys but the frequency was too low' do
      options[:from] = 30.days.ago

      # 1 deployment over 30 days
      # frequency of 0.03, rounded off to 0.0
      expect(subject).to eq('0')
    end

    it 'returns `-` when there were no deploys' do
      options[:from] = 4.days.ago

      # 0 deployment in the last 4 days
      expect(subject).to eq('-')
    end

    context 'when `to` is nil' do
      it 'includes range until now' do
        options[:from] = 6.days.ago
        options[:to] = nil

        # 1 deployment over 7 days
        expect(subject).to eq('0.1')
      end
    end

    context 'when `to` is given' do
      before do
        Timecop.freeze(5.days.from_now) { create(:deployment, :success, project: project) }
      end

      it 'finds records created between `from` and `to` range' do
        options[:from] = 10.days.ago
        options[:to] = 10.days.from_now

        # 2 deployments over 20 days
        expect(subject).to eq('0.1')
      end

      context 'when `from` and `to` are within a day' do
        it 'returns the number of deployments made on that day' do
          Timecop.freeze(Time.now) do
            create(:deployment, :success, project: project)
            options[:from] = options[:to] = Time.now

            expect(subject).to eq('1')
          end
        end
      end
    end
  end
end
