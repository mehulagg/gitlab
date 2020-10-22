# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/merge_requests/show.html.haml' do
  before do
    allow(view).to receive(:experiment_enabled?).and_return(false)
  end

  include_context 'merge request show action'

  context 'when merge request is created by a GitLab team member' do
    let(:user) { create(:user) }

    include_context 'gitlab team member'

    before do
      allow(Gitlab).to receive(:com?).and_return(true)
      allow(user).to receive(:gitlab_employee?).and_return(true)
    end

    it 'renders an employee badge next to their name' do
      render

      expect(rendered).to have_selector('[aria-label="GitLab Team Member"]')
    end
  end
end
