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

  def search
    subject.objects('projects').map { |project| project.compliance_framework_setting }
  end
end
