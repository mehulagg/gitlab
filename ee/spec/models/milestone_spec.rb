# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Milestone do
  describe "Associations" do
    it { is_expected.to have_many(:boards) }
  end

  context 'group milestone releases' do
    let(:user) { create(:user) }
    let(:issue) { create(:issue, project: project) }
    let(:project) { create(:project, :public) }
    let(:milestone) { build(:milestone, project: project) }

    before do
      allow(subject).to receive(:set_iid).and_return(false)
    end

    context 'when it is tied to a release for another project' do
      it 'creates a validation error' do
        other_project = create(:project)
        milestone.releases << build(:release, project: other_project)
        expect(milestone).not_to be_valid
      end
    end

    context 'when it is tied to a release for the same project' do
      it 'is valid' do
        milestone.releases << build(:release, project: project)
        expect(milestone).to be_valid
      end
    end
  end
end
