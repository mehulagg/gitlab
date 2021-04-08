# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::AutocompleteService do
  let_it_be(:group, refind: true) { create(:group, :nested, :private, avatar: fixture_file_upload('spec/fixtures/dk.png')) }
  let_it_be(:sub_group) { create(:group, :private, parent: group) }

  let(:user) { create(:user) }
  let!(:epic) { create(:epic, group: group, author: user) }

  subject { described_class.new(group, user) }

  before do
    group.add_developer(user)
  end

  def expect_labels_to_equal(labels, expected_labels)
    extract_title = lambda { |label| label['title'] }
    expect(labels.map(&extract_title)).to match_array(expected_labels.map(&extract_title))
  end

  describe '#labels_as_hash' do
    let!(:label1) { create(:group_label, group: group) }
    let!(:label2) { create(:group_label, group: group) }
    let!(:sub_group_label) { create(:group_label, group: sub_group) }
    let!(:parent_group_label) { create(:group_label, group: group.parent) }

    it 'returns labels from own group and ancestor groups' do
      results = subject.labels_as_hash(nil)

      expected_labels = [label1, label2, parent_group_label]

      expect_labels_to_equal(results, expected_labels)
    end

    context 'some labels are already assigned' do
      before do
        epic.labels << label1
      end

      it 'marks already assigned as set' do
        results = subject.labels_as_hash(epic)
        expected_labels = [label1, label2, parent_group_label]

        expect_labels_to_equal(results, expected_labels)

        assigned_label_titles = epic.labels.map(&:title)
        results.each do |hash|
          if assigned_label_titles.include?(hash['title'])
            expect(hash[:set]).to eq(true)
          else
            expect(hash.key?(:set)).to eq(false)
          end
        end
      end
    end
  end

  describe '#issues' do
    let(:project) { create(:project, group: group) }
    let(:sub_group_project) { create(:project, group: sub_group) }

    let!(:project_issue) { create(:issue, project: project) }
    let!(:sub_group_project_issue) { create(:issue, confidential: true, project: sub_group_project) }

    it 'returns issues in group and subgroups' do
      issues = subject.issues

      expect(issues.map(&:iid)).to contain_exactly(project_issue.iid, sub_group_project_issue.iid)
      expect(issues.map(&:title)).to contain_exactly(project_issue.title, sub_group_project_issue.title)
    end

    it 'returns only confidential issues if confidential_only is true' do
      issues = subject.issues(confidential_only: true)

      expect(issues.map(&:iid)).to contain_exactly(sub_group_project_issue.iid)
      expect(issues.map(&:title)).to contain_exactly(sub_group_project_issue.title)
    end
  end

  describe '#merge_requests' do
    let(:project) { create(:project, :repository, group: group) }
    let(:sub_group_project) { create(:project, :repository, group: sub_group) }

    let!(:project_mr) { create(:merge_request, source_project: project) }
    let!(:sub_group_project_mr) { create(:merge_request, source_project: sub_group_project) }

    it 'returns merge requests in group and subgroups' do
      expect(subject.merge_requests.map(&:iid)).to contain_exactly(project_mr.iid, sub_group_project_mr.iid)
      expect(subject.merge_requests.map(&:title)).to contain_exactly(project_mr.title, sub_group_project_mr.title)
    end
  end

  describe '#epics' do
    let(:expected_attributes) { %i(iid title group_id) }

    before do
      stub_licensed_features(epics: true)
    end

    it 'returns nothing if not allowed' do
      guest = create(:user)

      epics = described_class.new(group, guest).epics

      expect(epics).to be_empty
    end

    it 'returns epics from group' do
      result = subject.epics.map { |epic| epic.slice(expected_attributes) }

      expect(result).to contain_exactly(epic.slice(expected_attributes))
    end

    it 'returns only confidential epics if confidential_only is true' do
      confidential_epic = create(:epic, :confidential, group: group)

      result = subject.epics(confidential_only: true)
                 .map { |epic| epic.slice(expected_attributes) }

      expect(result).to contain_exactly(confidential_epic.slice(expected_attributes))
    end
  end

  describe '#vulnerability' do
    let_it_be_with_refind(:project) { create(:project, group: group) }
    let_it_be(:vulnerability) { create(:vulnerability, project: project) }
    let_it_be(:guest) { create(:user) }

    let(:autocomplete_user) { user }

    subject { described_class.new(group, autocomplete_user).vulnerabilities.map(&:id) }

    context 'when the feature is not available' do
      context 'when the user is not allowed' do
        it { is_expected.to be_empty }
      end

      context 'when the user is allowed' do
        before do
          project.add_developer(user)
        end

        it { is_expected.to be_empty }
      end
    end

    context 'when the feature is available' do
      before do
        stub_licensed_features(security_dashboard: true)
      end

      context 'when the user is not allowed' do
        let(:autocomplete_user) { guest }

        it { is_expected.to be_empty }
      end

      context 'when the user is allowed' do
        before do
          project.add_developer(user)
        end

        it { is_expected.to contain_exactly(vulnerability.id) }
      end
    end
  end

  describe '#commands' do
    context 'when target is an epic' do
      let(:parent_epic) { create(:epic, group: group, author: user) }
      let(:epic)        { create(:epic, group: group, author: user, parent: parent_epic) }

      context 'with subepics feature enabled' do
        before do
          stub_licensed_features(epics: true, subepics: true)
        end

        it 'returns available commands' do
          available_commands = [
            :todo, :unsubscribe, :award, :shrug, :tableflip, :cc, :title, :close,
            :child_epic, :remove_child_epic, :parent_epic, :remove_parent_epic
          ]

          expect(subject.commands(epic).map { |c| c[:name] }).to match_array(available_commands)
        end
      end

      context 'with subepics feature disabled' do
        before do
          stub_licensed_features(epics: true, subepics: false)
        end

        it 'returns available commands' do
          available_commands = [
            :todo, :unsubscribe, :award, :shrug, :tableflip, :cc, :title, :close
          ]

          expect(subject.commands(epic).map { |c| c[:name] }).to match_array(available_commands)
        end
      end
    end
  end

  describe '#milestones' do
    let!(:group_milestone) { create(:milestone, group: group) }
    let!(:subgroup_milestone) { create(:milestone, group: sub_group) }

    before do
      sub_group.add_maintainer(user)
    end

    context 'when group is public' do
      let(:public_group) { create(:group, :public) }
      let(:public_subgroup) { create(:group, :public, parent: public_group) }

      before do
        group_milestone.update(group: public_group)
        subgroup_milestone.update(group: public_subgroup)
      end

      it 'returns milestones from groups and subgroups' do
        subject = described_class.new(public_subgroup, user)

        expect(subject.milestones.map(&:iid)).to contain_exactly(group_milestone.iid, subgroup_milestone.iid)
        expect(subject.milestones.map(&:title)).to contain_exactly(group_milestone.title, subgroup_milestone.title)
      end
    end

    it 'returns milestones from group' do
      expect(subject.milestones.map(&:iid)).to contain_exactly(group_milestone.iid)
      expect(subject.milestones.map(&:title)).to contain_exactly(group_milestone.title)
    end

    it 'returns milestones from groups and subgroups' do
      milestones = described_class.new(sub_group, user).milestones

      expect(milestones.map(&:iid)).to contain_exactly(group_milestone.iid, subgroup_milestone.iid)
      expect(milestones.map(&:title)).to contain_exactly(group_milestone.title, subgroup_milestone.title)
    end

    it 'returns only milestones that user can read' do
      user = create(:user)
      sub_group.add_guest(user)

      milestones = described_class.new(sub_group, user).milestones

      expect(milestones.map(&:iid)).to contain_exactly(subgroup_milestone.iid)
      expect(milestones.map(&:title)).to contain_exactly(subgroup_milestone.title)
    end
  end
end
