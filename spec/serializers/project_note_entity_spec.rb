# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectNoteEntity do
  include Gitlab::Routing

  let(:request) { double('request', current_user: user, noteable: note.noteable) }

  let(:entity) { described_class.new(note, request: request) }
  let(:note) { create(:note) }
  let(:user) { create(:user) }

  subject { entity.as_json }

  it_behaves_like 'note entity'

  it 'exposes project-specific elements' do
    expect(subject).to include(:human_access, :toggle_award_path, :path)
  end

  it 'does not expose :diff_note_diff_path' do
    expect(subject).not_to include(:diff_note_diff_path)
  end

  context 'when note is part of resolvable discussion' do
    before do
      allow(note).to receive(:part_of_discussion?).and_return(true)
      allow(note).to receive(:resolvable?).and_return(true)
    end

    it 'exposes paths to resolve note' do
      expect(subject).to include(:resolve_path, :resolve_with_issue_path)
    end
  end

  context 'when note is a DiffNote' do
    let(:note) { create(:diff_note_on_merge_request) }

    it 'exposes :diff_note_diff_path' do
      expect(subject).to include(:diff_note_diff_path)
    end
  end
end
