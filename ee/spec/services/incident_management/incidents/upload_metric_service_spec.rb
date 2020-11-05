# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::Incidents::UploadMetricService do
  subject(:service) { described_class.new(issuable, current_user, params) }

  let_it_be(:project) { create(:project) }
  let_it_be(:issuable) { create(:incident, project: project) }
  let_it_be(:current_user) { create(:user) }
  let(:params) do
    {
      file: fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg'),
      url: 'https://www.gitlab.com'
    }
  end

  describe '#execute' do
    subject { service.execute }

    context 'user does not have permissions' do
      it 'returns an error and does not upload', :aggregate_failures do
        expect(subject).to eq({ message: 'Not allowed!', status: :error })
        expect(IncidentManagement::MetricImage.count).to eq(0)
      end
    end

    context 'user has permissions' do
      before_all do
        project.add_developer(current_user)
      end

      it 'uploads the metric and returns a success' do
        expect { subject }.to change(IncidentManagement::MetricImage, :count).by(1)
        expect(subject).to match({ metric: instance_of(IncidentManagement::MetricImage), issuable: issuable, status: :success })
      end

      context 'record invalid' do
        let(:params) do
          {
            file: fixture_file_upload('spec/fixtures/doc_sample.txt', 'text/plain'),
            url: nil
          }
        end

        it 'does not save the metric, and returns an error' do
          expect(subject).to include({ message: a_string_matching(/Validation failed/), status: :error })
          expect(IncidentManagement::MetricImage.count).to eq(0)
        end
      end
    end
  end
end
