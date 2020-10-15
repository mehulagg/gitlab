# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FeatureFlagsUserListsFinder, focus: true do
  let(:finder) { described_class.new(project, user, params) }
  let(:project) { create(:project, :repository) }
  let(:user) { project.creator }
  let(:user_list) { create(:operations_feature_flag_user_list, project: project) }
  let(:params) { {} }

  before do
    project.add_maintainer(user)
  end

  describe '#execute' do
    subject { finder.execute }

    it 'returns user lists' do
      is_expected.to contain_exactly(user_list)
    end

    context 'with search' do
      let!(:params) { { search: "test"} }
      let(:user_list_two) { create(:operations_feature_flag_user_list, name: 'testing', project: project) }

      it 'returns only matching user lists' do
        is_expected.to contain_exactly(user_list_two)
      end

    end
  end
  
end
