# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PendingTodosFinder do
  let_it_be(:user) { create(:user) }
  let_it_be(:todo_done) { create(:todo, :done, user: user) }
  let_it_be(:todo_pending) { create(:todo, :pending, user: user) }

  describe '#execute' do
    it 'returns only pending todos' do
      expect(described_class.new(user).execute).to eq([todo_pending])
    end

    it 'supports retrieving of todos for a specific project' do
      project1 = create(:project)
      project2 = create(:project)

      create(:todo, :pending, user: user, project: project2)

      todo = create(:todo, :pending, user: user, project: project1)
      todos = described_class.new(user, project_id: project1.id).execute

      expect(todos).to eq([todo])
    end

    it 'supports retrieving of todos for a specific todo target' do
      issue = create(:issue)
      note = create(:note)
      todo = create(:todo, :pending, user: user, target: issue)

      create(:todo, :pending, user: user, target: note)

      todos = described_class.new(user, target_id: issue.id).execute

      expect(todos).to eq([todo])
    end

    it 'supports retrieving of todos for a specific target type' do
      issue = create(:issue)
      note = create(:note)
      todo = create(:todo, :pending, user: user, target: issue)

      create(:todo, :pending, user: user, target: note)

      todos = described_class.new(user, target_type: issue.class.name).execute

      expect(todos).to eq([todo])
    end

    it 'supports retrieving of todos for a specific commit ID' do
      create(:todo, :pending, user: user, commit_id: '456')

      todo = create(:todo, :pending, user: user, commit_id: '123')
      todos = described_class.new(user, commit_id: '123').execute

      expect(todos).to eq([todo])
    end
  end
end
