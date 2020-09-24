# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notes::DestroyService do
  let_it_be(:project, refind: true) { create(:project) }
  let_it_be(:user) { create(:user) }

  let_it_be(:note, refind: true) do
    create(:note_on_issue, project: project, author: user)
  end

  subject(:service) { described_class.new(project, user) }

  describe '#execute' do
    describe 'refresh analytics comment data' do
      let(:analytics_mock) { instance_double('Analytics::RefreshCommentsData') }

      it 'invokes forced Analytics::RefreshCommentsData' do
        allow(Analytics::RefreshCommentsData).to receive(:for_note).with(note).and_return(analytics_mock)

        expect(analytics_mock).to receive(:execute).with(force: true)

        service.execute(note)
      end
    end

    describe 'publish to status page' do
      let(:execute) { service.execute(note) }
      let(:issue_id) { note.noteable_id }

      include_examples 'trigger status page publish'
    end
  end
end
