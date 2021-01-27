# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::RequirementsManagement::ExportRequirements do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:requirement) { create(:requirement, project: project) }
  let(:fields) { [] }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    shared_examples 'requirements not available' do
      it 'raises a not accessible error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    subject do
      mutation.resolve(
        project_path: project.full_path,
        author_username: user.username,
        state: 'OPENED',
        search: 'foo',
        selected_fields: fields
      )
    end

    it_behaves_like 'requirements not available'

    context 'when the user can export requirements' do
      before do
        project.add_developer(user)
      end

      context 'when requirements feature is available' do
        before do
          stub_licensed_features(requirements: true)
        end

        it 'export requirements' do
          args = { author_username: user.username, state: 'OPENED', search: 'foo', selected_fields: fields }

          expect(IssuableExportCsvWorker).to receive(:perform_async)
            .with(:requirement, user.id, project.id, args)

          subject
        end

        context 'with invalid arguments' do
          let(:fields) do
            ::RequirementsManagement::ExportCsvService::PERMITTED_FIELDS + ['created at', 'username']
          end

          it 'raises an error with expected message' do
            expect { subject }
              .to raise_error(Gitlab::Graphql::Errors::ArgumentError,
                "The following fields are incorrect: created at, username."\
                " See https://docs.gitlab.com/ee/user/project/requirements/#exported-csv-file-format"\
                " for permitted fields.")
          end
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
