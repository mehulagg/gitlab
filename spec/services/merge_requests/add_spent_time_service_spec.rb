# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::AddSpentTimeService do
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:merge_request) { create(:merge_request, :simple, :unique_branches, source_project: project) }
  let_it_be(:user) { create(:user) }

  let(:params) { { spend_time: { duration: 1500, user_id: user.id } } }
  let(:service) { described_class.new(project, user, params) }

  describe '#execute' do
    before do
      project.add_developer(user)
    end

    it 'creates a new timelog with the specified duration' do
      expect { service.execute(merge_request) }.to change { Timelog.count }.from(0).to(1)

      expect(merge_request.timelogs.last.time_spent).to eq(1500)
    end

    it 'is more efficient than using the full update-service' do
      other_mr = create(:merge_request, :simple, :unique_branches, source_project: project)

      update_service = ::MergeRequests::UpdateService.new(project, user, params)

      expect { service.execute(merge_request) }
        .to issue_fewer_queries_than { update_service.execute(other_mr) }
    end
  end
end
