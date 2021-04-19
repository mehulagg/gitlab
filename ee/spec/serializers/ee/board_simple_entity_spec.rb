# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BoardSimpleEntity, let_it_be_light_freeze: false do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project) }
  let_it_be(:board) { create(:board, project: project) }

  subject { described_class.new(board).as_json }

  describe '#milestone' do
    let_it_be(:milestone) { create(:milestone) }

    it 'has no `milestone` attribute' do
      expect(subject).not_to include(:milestone)
    end

    it 'has `milestone` attribute' do
      board.milestone_id = milestone.id

      expect(subject).to include(:milestone)
      expect(subject[:milestone]).to eq({ id: milestone.id, title: milestone.title })
    end
  end

  describe '#iteration' do
    let_it_be(:iteration) { create(:iteration, group: group) }

    it 'has no `iteration` attribute' do
      expect(subject).not_to include(:iteration)
    end

    it 'has `iteration` attribute' do
      board.iteration_id = iteration.id

      expect(subject).to include(:iteration)
      expect(subject[:iteration]).to eq({ id: iteration.id, title: iteration.title })
    end
  end
end
