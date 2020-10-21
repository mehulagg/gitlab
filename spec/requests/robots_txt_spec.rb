# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Robots.txt Requests', :aggregate_failures do
  before do
    Gitlab::Testing::RobotsBlockerMiddleware.block_requests!
  end

  after do
    Gitlab::Testing::RobotsBlockerMiddleware.allow_requests!
  end

  it 'allows the requests' do
    requests = [
      '/users/foo/snippets',
      '/users/foo/snippets/1',
      '/users/sign_in'
    ]

    requests.each do |request|
      get request

      expect(response).not_to have_gitlab_http_status(:service_unavailable)
    end
  end

  it 'blocks the requests' do
    requests = [
      '/autocomplete/users',
      '/search',
      '/admin',
      '/profile',
      '/dashboard',
      '/users',
      '/users/foo',
      '/help',
      '/s/',
      '/foo/bar/new',
      '/foo/bar/edit',
      '/foo/bar/raw',
      '/groups/foo/analytics',
      '/groups/foo/contribution_analytics',
      '/groups/foo/group_members',
      '/foo/bar/project.git',
      '/foo/bar/archive/foo',
      '/foo/bar/repository/archive',
      '/foo/bar/activity',
      '/foo/bar/blame',
      '/foo/bar/commits',
      '/foo/bar/commit',
      '/foo/bar/compare',
      '/foo/bar/network',
      '/foo/bar/graphs',
      '/foo/bar/merge_requests/1.patch',
      '/foo/bar/merge_requests/1.diff',
      '/foo/bar/merge_requests/1/diffs',
      '/foo/bar/deploy_keys',
      '/foo/bar/hooks',
      '/foo/bar/services',
      '/foo/bar/protected_branches',
      '/foo/bar/uploads/foo',
      '/foo/bar/project_members',
      '/foo/bar/settings',
      '/users/foo/snippetsfoo',
    ]

    requests.each do |request|
      get request

      expect(response).to have_gitlab_http_status(:service_unavailable)
    end
  end
end
