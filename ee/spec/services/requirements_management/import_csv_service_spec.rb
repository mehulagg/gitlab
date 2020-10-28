# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::ImportCsvService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  subject do
    uploader = FileUploader.new(project)
    uploader.store!(file)

    described_class.new(user, project, uploader).execute
  end

  describe '#execute' do
    context 'when user can create requirements' do
      before do
        project.add_reporter(user)
        stub_licensed_features(requirements: true)
      end

      context 'invalid file' do
        let(:file) { fixture_file_upload('spec/fixtures/banana_sample.gif') }

        it 'returns invalid file error' do
          expect(Notify).to receive_message_chain(:import_requirements_csv_email, :deliver_later)

          expect(subject[:success]).to eq(0)
          expect(subject[:parse_error]).to eq(true)
        end
      end

      context 'comma delimited file' do
        let(:file) { fixture_file_upload('spec/fixtures/csv_comma.csv') }

        it 'imports CSV without errors' do
          expect(Notify).to receive_message_chain(:import_requirements_csv_email, :deliver_later)

          expect(subject[:success]).to eq(3)
          expect(subject[:error_lines]).to eq([])
          expect(subject[:parse_error]).to eq(false)
        end

        it 'correctly sets the requirement attributes' do
          expect { subject }.to change { project.requirements.count }.by 3

          expect(project.requirements.reload.last).to have_attributes(
            title: 'Title with quote"',
            description: 'Description'
          )
        end
      end

      context 'tab delimited file with error row' do
        let(:file) { fixture_file_upload('spec/fixtures/csv_tab.csv') }

        it 'imports CSV with some error rows' do
          expect(Notify).to receive_message_chain(:import_requirements_csv_email, :deliver_later)

          expect(subject[:success]).to eq(2)
          expect(subject[:error_lines]).to eq([3])
          expect(subject[:parse_error]).to eq(false)
        end

        it 'correctly sets the requirement attributes' do
          expect { subject }.to change { project.requirements.count }.by 2

          expect(project.requirements.reload.last).to have_attributes(
            title: 'Hello',
            description: 'World'
          )
        end
      end

      context 'semicolon delimited file with CRLF' do
        let(:file) { fixture_file_upload('spec/fixtures/csv_semicolon.csv') }

        it 'imports CSV with a blank row' do
          expect(Notify).to receive_message_chain(:import_requirements_csv_email, :deliver_later)

          expect(subject[:success]).to eq(3)
          expect(subject[:error_lines]).to eq([4])
          expect(subject[:parse_error]).to eq(false)
        end

        it 'correctly sets the requirement attributes' do
          expect { subject }.to change { project.requirements.count }.by 3

          expect(project.requirements.reload.last).to have_attributes(
            title: 'Hello',
            description: 'World'
          )
        end
      end
    end

    context 'when user cannot create requirements' do
      let(:file) { fixture_file_upload('spec/fixtures/csv_comma.csv') }

      it 'raises an exception' do
        expect { subject }.to raise_error(Gitlab::Access::AccessDeniedError)
      end
    end
  end
end
