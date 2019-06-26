require 'spec_helper'

describe Gitlab::CycleAnalytics::GroupStageSummary do
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:project_2) { create(:project, :repository, namespace: group) }
  let(:from) { 1.day.ago }
  let(:user) { create(:user, :admin) }
  subject { described_class.new(group, from: Time.now, current_user: user).data }

  describe "#new_issues" do
    it "finds the number of issues created after the 'from date'" do
      Timecop.freeze(5.days.ago) { create(:issue, project: project) }
      Timecop.freeze(5.days.ago) { create(:issue, project: project_2) }
      Timecop.freeze(5.days.from_now) { create(:issue, project: project) }
      Timecop.freeze(5.days.from_now) { create(:issue, project: project_2) }

      expect(subject.first[:value]).to eq(2)
    end

    it "doesn't find issues from other projects" do
      Timecop.freeze(5.days.from_now) { create(:issue, project: create(:project, namespace: create(:group))) }
      Timecop.freeze(5.days.from_now) { create(:issue, project: project) }
      Timecop.freeze(5.days.from_now) { create(:issue, project: project_2) }

      expect(subject.first[:value]).to eq(2)
    end
  end

  # describe "#commits" do
  #   it "finds the number of commits created after the 'from date'" do
  #     Timecop.freeze(5.days.ago) { create_commit("Test message", project, user, 'master') }
  #     Timecop.freeze(5.days.from_now) { create_commit("Test message", project_2, user, 'master') }
  #     Timecop.freeze(5.days.from_now) { create_commit("Test message", project, user, 'master') }

  #     expect(subject.second[:value]).to eq(2)
  #   end

  #   it "doesn't find commits from other projects" do
  #     Timecop.freeze(5.days.from_now) { create_commit("Test message", create(:project, :repository, namespace: create(:group)), user, 'master') }

  #     expect(subject.second[:value]).to eq(0)
  #   end

  #   it "finds a large (> 100) snumber of commits if present" do
  #     Timecop.freeze(5.days.from_now) { create_commit("Test message", project, user, 'master', count: 51) }
  #     Timecop.freeze(5.days.from_now) { create_commit("Test message", project_2, user, 'master', count: 51) }

  #     expect(subject.second[:value]).to eq(100)
  #   end
  # end

  describe "#deploys" do
    it "finds the number of deploys made created after the 'from date'" do
      Timecop.freeze(5.days.ago) { create(:deployment, :success, project: project) }
      Timecop.freeze(5.days.from_now) { create(:deployment, :success, project: project) }
      Timecop.freeze(5.days.ago) { create(:deployment, :success, project: project_2) }
      Timecop.freeze(5.days.from_now) { create(:deployment, :success, project: project_2) }

      expect(subject.third[:value]).to eq(2)
    end

    it "doesn't find commits from other projects" do
      Timecop.freeze(5.days.from_now) do
        create(:deployment, :success, project: create(:project, :repository, namespace: create(:group)))
      end

      expect(subject.third[:value]).to eq(0)
    end
  end
end
