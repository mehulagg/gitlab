# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/issues/show' do
  include_context 'project show action'

  context 'when issue is created by a GitLab team member' do
    let(:user) { create(:user) }

    include_context 'gitlab team member'

    before do
      allow(Gitlab).to receive(:com?).and_return(true)
    end

    it 'renders an employee badge next to their name' do
      render

      expect(rendered).to have_selector('[aria-label="GitLab Team Member"]')
    end
  end

  context 'for applicable incidents' do
    before do
      allow(view).to receive(:show_timeline_view_toggle?).and_return(true)
    end

    it 'renders a timeline toggle' do
      render

      expect(rendered).to have_selector('#js-incidents-timeline-toggle')
    end
  end
end
