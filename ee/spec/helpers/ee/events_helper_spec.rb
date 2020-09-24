# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventsHelper do
  describe '#event_note_target_url' do
    subject { helper.event_note_target_url(event) }

    context 'for epic note events' do
      let_it_be(:group) { create(:group, :public) }
      let_it_be(:event) { create(:event, group: group) }

      it 'returns an epic url' do
        event.target = create(:note_on_epic, note: 'foo')

        expect(subject).to match("#{group.to_param}/-/epics/#{event.note_target.iid}#note_#{event.target.id}")
      end
    end
  end
end
