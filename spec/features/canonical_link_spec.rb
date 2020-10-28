# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Canonical link' do
  include Spec::Support::Helpers::Features::CanonicalLinkHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, :repository, namespace: group) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

  before_all do
    group.add_owner(user)
  end

  before do
    sign_in(user)
  end

  shared_examples 'shows canonical link' do
    specify do
      visit request_url

      expect(page).to have_canonical_link(expected_url)
    end
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { issue_url(issue) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_issues_url(project) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_issues_url(project, state: 'opened') }
    let(:expected_url) { project_issues_url(project) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_merge_request_url(project, merge_request) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_merge_requests_url(project) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_merge_requests_url(project, state: 'opened') }
    let(:expected_url) { project_merge_requests_url(project) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { group_url(group) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { group_shared_url(group) }
    let(:expected_url) { group_url(group) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { user_url(user) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { dashboard_groups_url }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { project_url(project) }
    let(:expected_url) { request_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request_url) { explore_root_path }
    let(:expected_url) { explore_projects_url }
  end

  context 'when feature flag global_canonical is disabled' do
    shared_examples 'does not show canonical link' do
      specify do
        stub_feature_flags(global_canonical: false)

        visit request_url

        expect(page).not_to have_any_canonical_links
      end
    end

    it_behaves_like 'does not show canonical link' do
      let(:request_url) { issue_url(issue) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request_url) { project_merge_request_url(project, merge_request) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request_url) { user_url(user) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request_url) { project_url(project) }
    end
  end
end
