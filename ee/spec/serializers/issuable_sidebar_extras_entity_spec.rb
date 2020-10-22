# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuableSidebarExtrasEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:resource) { create(:issue, project: project, assignees: [user]) }
  let(:request) { double('request', current_user: user) }

  subject { described_class.new(resource, request: request).as_json }

  context 'when the gitlab_employee_badge flag is off' do
    it 'does not expose the is_gitlab_employee field for assignees' do
      stub_feature_flags(gitlab_employee_badge: false)

      expect(subject[:assignees].first).not_to include(:is_gitlab_employee)
    end
  end

  context 'when the gitlab_employee_badge flag is on but we are not on gitlab.com' do
    it 'does not expose the is_gitlab_employee field for assignees' do
      stub_feature_flags(gitlab_employee_badge: true)
      allow(Gitlab).to receive(:com?).and_return(false)

      expect(subject[:assignees].first).not_to include(:is_gitlab_employee)
    end
  end

  context 'when gitlab_employee_badge flag is on and we are on gitlab.com' do
    it 'exposes is_gitlab_employee field for assignees' do
      stub_feature_flags(gitlab_employee_badge: true)
      allow(Gitlab).to receive(:com?).and_return(true)

      expect(subject[:assignees].first).to include(:is_gitlab_employee)
    end
  end
end
