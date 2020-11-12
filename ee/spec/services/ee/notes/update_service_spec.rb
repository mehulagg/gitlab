# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notes::UpdateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let_it_be(:note, refind: true) do
    create(:note_on_issue, project: project, author: user)
  end

  subject(:service) { described_class.new(project, user, opts) }

  describe '#execute' do
    let(:opts) { { note: note_text } }

    describe 'publish to status page' do
      let(:execute) { service.execute(note) }
      let(:issue_id) { note.noteable_id }
      let(:emoji_name) { Gitlab::StatusPage::AWARD_EMOJI }

      before do
        create(:award_emoji, user: user, name: emoji_name, awardable: note)
      end

      context 'for text-only update' do
        let(:note_text) { 'text' }

        include_examples 'trigger status page publish'

        context 'without recognized emoji' do
          let(:emoji_name) { 'thumbsup' }

          include_examples 'no trigger status page publish'
        end
      end

      context 'for quick action only update' do
        let(:note_text) { "/todo\n" }

        include_examples 'trigger status page publish'
      end

      context 'when update fails' do
        let(:note_text) { '' }

        include_examples 'no trigger status page publish'
      end
    end
  end
end
