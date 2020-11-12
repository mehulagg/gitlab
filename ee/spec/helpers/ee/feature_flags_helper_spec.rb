# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::FeatureFlagsHelper do
  let_it_be(:project) { create(:project) }
  let_it_be(:feature_flag) { create(:operations_feature_flag, project: project) }
  let_it_be(:user) { create(:user) }

  describe '#feature_flag_issues_links_endpoint' do
    subject { helper.feature_flag_issues_links_endpoint(project, feature_flag, user) }

    it 'returns an empty string when the user is not allowed' do
      allow(helper).to receive(:can?).with(user, :admin_feature_flags_issue_links, project).and_return(false)

      is_expected.to be_empty
    end

    it 'returns the issue endpoint when the user is allowed' do
      allow(helper).to receive(:can?).with(user, :admin_feature_flags_issue_links, project).and_return(true)

      is_expected.to eq("/#{project.full_path}/-/feature_flags/#{feature_flag.iid}/issues")
    end
  end
end
