# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::UploadMetric do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be_with_refind(:project) { create(:project, :public) }
  let_it_be(:issue) { create(:incident, project: project) }
  let(:file) { fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg') }

  subject(:mutation) do
    described_class.new(object: nil, context: { current_user: current_user }, field: nil)
  end

  describe '#resolve' do
    subject(:resolve) do
      mutation.resolve(project_path: project.full_path, iid: issue.iid, file: file, url: 'http://www.gitlab.com')
    end

    context 'user has no permission' do
      it "raises an error" do
        expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'user has permission' do
      before do
        project.add_developer(current_user)
      end

      it 'returns an error' do
        expect { subject }
              .not_to change(issue.metric_images, :count)

        expect(subject[:errors]).to include('Not allowed!')
      end

      context 'with license' do
        before do
          stub_licensed_features(incident_metric_upload: true)
        end

        it 'creates the metric image' do
          expect { subject }
            .to change(issue.metric_images, :count)

          expect(subject[:issue]).to eq(issue)
          expect(subject[:errors]).to be_empty
        end

        context 'file size is too large' do
          before do
            allow(file).to receive(:size).and_return(2.megabytes)
          end

          it 'returns an error' do
            expect { subject }
              .not_to change(issue.metric_images, :count)

            expect(subject[:errors]).to include('File size too large!')
          end
        end
      end
    end
  end
end
