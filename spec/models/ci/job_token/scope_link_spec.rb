# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::JobToken::ScopeLink do
  it { is_expected.to belong_to(:source_project) }
  it { is_expected.to belong_to(:target_project) }
  it { is_expected.to belong_to(:added_by) }

  describe 'unique index' do
    let!(:link) { create(:ci_job_token_scope_link) }

    it 'raises an error' do
      expect do
        create(:ci_job_token_scope_link, link.attributes)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe '.from_project' do
    let(:project) { create(:project) }

    subject { described_class.from_project(project) }

    let!(:source_link) { create(:ci_job_token_scope_link, source_project: project) }
    let!(:target_link) { create(:ci_job_token_scope_link, target_project: project) }

    it 'returns only the links having the given source project' do
      expect(subject).to contain_exactly(source_link)
    end
  end

  describe '.to_project' do
    let(:project) { create(:project) }

    subject { described_class.to_project(project) }

    let!(:source_link) { create(:ci_job_token_scope_link, source_project: project) }
    let!(:target_link) { create(:ci_job_token_scope_link, target_project: project) }

    it 'returns only the links having the given target project' do
      expect(subject).to contain_exactly(target_link)
    end
  end
end
