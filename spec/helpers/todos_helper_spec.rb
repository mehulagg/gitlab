# frozen_string_literal: true

require 'spec_helper'

describe TodosHelper do
  let_it_be(:user) { create(:user) }
  let_it_be(:author) { create(:user) }
  let_it_be(:issue) { create(:issue) }
  let_it_be(:design) { create(:design, issue: issue) }
  let_it_be(:note) do
    create(:note,
           project: issue.project,
           note: 'I am note, hear me roar')
  end
  let_it_be(:design_todo) do
    create(:todo, :mentioned,
           user: user,
           project: issue.project,
           target: design,
           author: author,
           note: note)
  end

  describe '#todos_count_format' do
    it 'shows fuzzy count for 100 or more items' do
      expect(helper.todos_count_format(100)).to eq '99+'
      expect(helper.todos_count_format(1000)).to eq '99+'
    end

    it 'shows exact count for 99 or fewer items' do
      expect(helper.todos_count_format(99)).to eq '99'
      expect(helper.todos_count_format(50)).to eq '50'
      expect(helper.todos_count_format(1)).to eq '1'
    end
  end

  describe '#todo_projects_options' do
    let(:projects) { create_list(:project, 3) }
    let(:user)     { create(:user) }

    it 'returns users authorised projects in json format' do
      projects.first.add_developer(user)
      projects.second.add_developer(user)

      allow(helper).to receive(:current_user).and_return(user)

      expected_results = [
        { 'id' => '', 'text' => 'Any Project' },
        { 'id' => projects.second.id, 'text' => projects.second.full_name },
        { 'id' => projects.first.id, 'text' => projects.first.full_name }
      ]

      expect(Gitlab::Json.parse(helper.todo_projects_options)).to match_array(expected_results)
    end
  end

  describe '#todo_target_link' do
    context 'when given a design' do
      let(:todo) { design_todo }

      it 'produces a good link' do
        path = helper.todo_target_path(todo)
        link = helper.todo_target_link(todo)
        expected = "<a href=\"#{path}\">design #{design.to_reference}</a>"

        expect(link).to eq(expected)
      end
    end
  end

  describe '#todo_target_path' do
    context 'when given a design' do
      let(:todo) { design_todo }

      it 'responds with an appropriate path' do
        path = helper.todo_target_path(todo)
        issue_path = Gitlab::Routing.url_helpers
          .project_issue_path(issue.project, issue)

        expect(path).to eq("#{issue_path}/designs/#{design.filename}##{dom_id(design_todo.note)}")
      end
    end
  end

  describe '#todo_target_type_name' do
    context 'when given a design todo' do
      let(:todo) { design_todo }

      it 'responds with an appropriate target type name' do
        name = helper.todo_target_type_name(todo)

        expect(name).to eq('design')
      end
    end
  end

  describe '#todo_types_options' do
    it 'includes a match for a design todo' do
      options = helper.todo_types_options
      design_option = options.find { |o| o[:id] == design_todo.target_type }

      expect(design_option).to include(text: 'Design')
    end
  end
end
