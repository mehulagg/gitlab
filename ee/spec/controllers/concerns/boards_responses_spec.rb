# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardsResponses do
  let(:controller_class) do
    Class.new do
      include BoardsResponses
    end
  end

  subject(:controller) { controller_class.new }

  before do
    stub_licensed_features(scoped_issue_board: true)
  end

  describe '#serialize_as_json' do
    let(:milestone) { nil }
    let(:iteration) { nil }
    let(:board) { create(:board, milestone: milestone, iteration: iteration) }

    context 'without milestone or iteration' do
      it 'serialises properly' do
        expected = { id: board.id, name: board.name }.as_json

        expect(subject.serialize_as_json(board)).to match(expected)
      end
    end

    context 'with milestone' do
      let_it_be(:milestone) { build_stubbed(:milestone) }

      it 'serialises properly' do
        expected = { id: board.id, name: board.name, milestone: { id: milestone.id, title: milestone.title } }.as_json

        expect(subject.serialize_as_json(board)).to match(expected)
      end
    end

    context 'with iteration' do
      let_it_be(:iteration) { build_stubbed(:iteration) }

      it 'serialises properly' do
        expected = { id: board.id, name: board.name, iteration: { id: iteration.id, title: iteration.title } }.as_json

        expect(subject.serialize_as_json(board)).to match(expected)
      end
    end
  end
end
