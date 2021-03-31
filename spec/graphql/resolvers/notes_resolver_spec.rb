# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::NotesResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:note1) { create(:note, noteable: issue, project: project, created_at: 3.hours.ago) }
  let_it_be(:note2) { create(:note, noteable: issue, project: project, created_at: 4.hours.ago) }
  let_it_be(:note3) { create(:note, noteable: issue, project: project, created_at: 5.hours.ago) }
  let_it_be(:note4) { create(:note, noteable: issue, project: project, created_at: 2.hours.ago) }
  let_it_be(:note5) { create(:note) }

  specify do
    expect(described_class).to have_non_null_graphql_type(Types::Notes::NoteType.connection_type)
  end

  before_all do
    project.add_developer(current_user)
  end

  describe '#resolve' do
    it 'returns all notes' do
      expect(resolve_notes).to contain_exactly(note1, note2, note3, note4)
    end

    describe 'sorting' do
      it 'sorts notes by created_at ascending' do
        expect(resolve_notes(sort: 'created_at_asc').to_a).to eq [note3, note2, note1, note4]
      end

      it 'sorts notes by created_at descending' do
        expect(resolve_notes(sort: 'created_at_desc').to_a).to eq [note4, note1, note2, note3]
      end
    end
  end

  def resolve_notes(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: issue, args: args, ctx: context)
  end
end
