# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['IssueConnection'] do
  describe '#weight' do
    subject(:response) { GitlabSchema.execute(query, context: { current_user: current_user }) }

    let(:query) do
      %(
          query{
            project(fullPath:"#{project.full_path}"){
              issues{
                weight
              }
            }
          }
        )
    end

    let_it_be(:project) { create :project, :public }
    let_it_be(:current_user) { create :admin }

    before do
      create :issue, project: project, weight: 2
      create :issue, project: project, weight: 7
      create :issue, project: project, weight: nil
    end

    it 'returns sum of all weights' do
      expect(response.dig(*%w[data project issues weight])).to eq 9
    end
  end
end
