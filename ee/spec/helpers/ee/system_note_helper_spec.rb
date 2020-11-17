# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SystemNoteHelper do
  describe '.system_note_icon_name' do
    subject(:system_note_icon_name) { helper.system_note_icon_name(note) }

    context 'for an iteration note' do
      let(:iteration_event) { build_stubbed(:resource_iteration_event) }
      let(:note) { IterationNote.from_event(iteration_event, resource: iteration_event.issue) }

      it 'returns the iteration icon name' do
        expect(system_note_icon_name).to eq('iteration')
      end
    end
  end
end
