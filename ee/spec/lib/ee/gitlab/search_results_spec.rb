# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SearchResults do
  let(:user) { build(:user) }

  let_it_be(:compliance_project) { create(:project, :with_compliance_framework, name: 'foo') }

  subject { described_class.new(user, 'foo') }

  describe '#projects' do
    it 'avoid N+1 queries' do
      control = ActiveRecord::QueryRecorder.new { search }

      create_list(:project, 2, :with_compliance_framework, name: 'foo')

      # Expected queries when searching for Projects
      #
      # 1. On the projects table
      # 2. On the project_compliance_framework_settings table for framework names
      #
      expect { search }.not_to exceed_query_limit(control)
    end
  end

  describe '#epics' do
    let!(:group) { create(:group, :private) }
    let!(:searchable_epic) { create(:epic, title: 'foo', group: group) }
    let!(:another_group) { create(:group, :private) }
    let!(:another_epic) { create(:epic, title: 'foo 2', group: another_group) }

    before do
      create(:group_member, group: group, user: user)
      group.add_owner(user)
    end

    it 'finds epics' do
      expect(subject.objects('epics')).to match_array([searchable_epic])
    end
  end

  def search
    subject.objects('projects').map { |project| project.compliance_framework_setting.framework }
  end
end
