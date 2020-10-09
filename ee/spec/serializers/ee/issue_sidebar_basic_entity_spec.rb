# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::IssueSidebarBasicEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:issue) { create(:issue, project: project, assignees: [user]) }

  context "When serializing" do
    let(:test_value) { 'TEST VALUE' }

    before do
      allow_any_instance_of(EE::CveRequestHelper).to receive(:request_cve_enabled_for_user?).and_return(test_value)
    end

    it 'uses the value from request_cve_enabled_for_user' do
      serializer = IssueSerializer.new(current_user: user, project: project)
      data = serializer.represent(issue, serializer: 'sidebar')
      expect(data[:request_cve_enabled_for_user]).to equal(test_value)
    end
  end
end
