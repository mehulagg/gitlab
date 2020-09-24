# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Branches::DeleteService do
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }
  let(:service) { described_class.new(project, user) }

  shared_examples 'a deleted branch' do |branch_name|
    it 'removes the branch' do
      expect(branch_exists?(branch_name)).to be true

      result = service.execute(branch_name)

      expect(result.status).to eq :success
      expect(branch_exists?(branch_name)).to be false
    end
  end

  describe '#execute' do
    context 'when there is a push rule matching the branch name' do
      before do
        project.add_developer(user)
        create(:push_rule, branch_name_regex: '^(w*)$')
      end

      it_behaves_like 'a deleted branch', 'add-pdf-file'
    end
  end

  def branch_exists?(branch_name)
    repository.ref_exists?("refs/heads/#{branch_name}")
  end
end
