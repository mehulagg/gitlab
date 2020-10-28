# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Canonical link' do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :public, namespace: group) }
  let_it_be(:issue) { create(:issue, project: project) }

  before_all do
    group.add_owner(user)
    sign_in(user)
  end

  shared_examples 'shows canonical link' do
    specify do
      visit request

      expect(page).to have_canonical_link(expected_url)
    end
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { issue_url(issue) }
    let(:expected_url) { request }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { project_issues_url(project, scope: 'all', state: 'opened', search: 'foo') }
    let(:expected_url) { project_issues_url(project) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { group_url(group) }
    let(:expected_url) { request }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { group_shared_url(group) }
    let(:expected_url) { group_url(group) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { group_shared_url(group) }
    let(:expected_url) { group_url(group) }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { dashboard_groups_url(search: 'foo') }
    let(:expected_url) { dashboard_groups_url }
  end

  it_behaves_like 'shows canonical link' do
    let(:request) { project_url(project) }
    let(:expected_url) { request }
  end

  context 'when feature flag global_canonical is disabled' do
    shared_examples 'does not show canonical link' do
      specify do
        stub_feature_flags(global_canonical: false)

        visit request

        expect(page).not_to have_any_canonical_links
      end
    end

    it_behaves_like 'does not show canonical link' do
      let(:request) { issue_url(issue) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request) { project_issues_url(project) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request) { user_url(user) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request) { group_url(group) }
    end

    it_behaves_like 'does not show canonical link' do
      let(:request) { project_url(project) }
    end
  end
end
