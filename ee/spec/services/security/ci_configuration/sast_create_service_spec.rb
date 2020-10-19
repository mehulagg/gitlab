# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CiConfiguration::SastCreateService do
  describe '#execute' do
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:user) { create(:user) }

    subject(:result) { described_class.new(project, user, params).execute }

    before do
      project.add_developer(user)
    end

    context 'with no parameters' do
      let(:params) { {} }

      it 'returns the path to create a new merge request' do
        expect(result[:status]).to eq(:success)
        expect(result[:success_path]).to match(/#{Gitlab::Routing.url_helpers.project_new_merge_request_url(project, {})}(.*)description(.*)source_branch/)
      end

      it 'raises exception if the user does not have permission to create a new branch' do
        allow(project).to receive(:repository).and_raise(Gitlab::Git::PreReceiveError, "You are not allowed to create protected branches on this project.")

        expect { subject  }.to raise_error(Gitlab::Git::PreReceiveError)
      end
    end
  end
end
