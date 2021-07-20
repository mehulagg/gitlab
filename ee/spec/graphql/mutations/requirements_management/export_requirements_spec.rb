# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::RequirementsManagement::ExportRequirements do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let(:fields) { [] }
  let(:args) do
    {
      project_path: project.full_path,
      author_username: user.username,
      state: 'OPENED',
      search: 'foo',
      selected_fields: fields
    }
  end

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#ready' do
    context 'with selected fields argument' do
      let(:fields) { ['title', 'description', 'created at', 'username'] }

      it 'raises exception when invalid fields are given' do
        expect { mutation.ready?(**args) }
          .to raise_error(Gitlab::Graphql::Errors::ArgumentError,
            "The following fields are incorrect: created at, username."\
            " See https://docs.gitlab.com/ee/user/project/requirements/#exported-csv-file-format"\
            " for permitted fields.")
      end
    end
  end

  describe '#resolve' do
    shared_examples 'requirements not available' do
      it 'raises a not accessible error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    subject { mutation.resolve(**args) }

    it_behaves_like 'requirements not available'

    context 'when the user can export requirements' do
      before do
        project.add_developer(user)
      end

      context 'when requirements feature is available' do
        before do
          stub_licensed_features(requirements: true)
        end

        it 'exports requirements' do
          expect(IssuableExportCsvWorker).to receive(:perform_async)
            .with(:requirement, user.id, project.id, args.except(:project_path))

          subject
        end
      end

      context 'when requirements feature is disabled' do
        before do
          stub_licensed_features(requirements: false)
        end

        it_behaves_like 'requirements not available'
      end
    end
  end
end
