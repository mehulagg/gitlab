# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Entities::BasicProjectDetails do
  let_it_be(:project) { create(:project) }

  let(:current_user) { project.owner }

  subject(:output) { described_class.new(project, current_user: current_user).as_json }

  describe '#default_branch' do
    it 'delegates to Project#default_branch' do
      expect(project).to receive(:default_branch).twice.and_call_original

      expect(output).to include(default_branch: project.default_branch)
    end

    context 'anonymous user' do
      let(:current_user) { nil }

      it 'is not included' do
        expect(output.keys).not_to include(:default_branch)
      end
    end
  end
end
