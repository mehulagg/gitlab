# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::AddSpentTimeService do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be_with_reload(:merge_request) { create(:merge_request, :simple, :unique_branches, source_project: project) }

  let(:params) { { spend_time: { duration: 1500, user_id: user.id } } }
  let(:service) { described_class.new(project, user, params) }

  describe '#execute' do
    before do
      project.add_developer(user)
    end

    it 'creates a new timelog with the specified duration' do
      expect { service.execute(merge_request) }.to change { Timelog.count }.from(0).to(1)

      timelog = merge_request.timelogs.last

      expect(timelog).not_to be_nil
      expect(timelog.time_spent).to eq(1500)
    end

    it 'creates a system note with the time added' do
      expect { service.execute(merge_request) }.to change { Note.count }.from(0).to(1)

      system_note = merge_request.notes.last

      expect(system_note).not_to be_nil
      expect(system_note.note_html).to include('added 25m of time spent')
    end

    it 'saves usage data' do
      expect(Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter)
        .to receive(:track_time_spent_changed_action).once.with(user: user)

      service.execute(merge_request)
    end

    it 'is more efficient than using the full update-service' do
      other_mr = create(:merge_request, :simple, :unique_branches, source_project: project)

      update_service = ::MergeRequests::UpdateService.new(project, user, params)

      expect { service.execute(merge_request) }
        .to issue_fewer_queries_than { update_service.execute(other_mr) }
    end
  end
end
