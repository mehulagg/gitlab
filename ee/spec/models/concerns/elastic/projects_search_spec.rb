# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Elastic::ProjectsSearch do
  subject do
    Class.new do
      include Elastic::ProjectsSearch

      def id
        1
      end

      def es_id
        1
      end
    end.new
  end

  describe '#maintain_elasticsearch_create' do
    it 'calls track!' do
      expect(::Elastic::ProcessInitialBookkeepingService).to receive(:track!).and_return(true)

      subject.maintain_elasticsearch_create
    end
  end

  describe '#maintain_elasticsearch_destroy' do
    it 'calls delete worker' do
      expect(ElasticDeleteProjectWorker).to receive(:perform_async)

      subject.maintain_elasticsearch_destroy
    end
  end

  describe '#maintain_elasticsearch_update' do
    before do
      stub_ee_application_setting(elasticsearch_indexing: true)
    end
    let!(:project) { create(:project) }
    let!(:issues) { create_list(:issue, 3, project: project) }

    it 'indexes issues if visibility_level is updated', :aggregate_failures do
      expect(::Elastic::ProcessBookkeepingService).to receive(:track!)
      expect(::Elastic::ProcessBookkeepingService).to receive(:track!).with(issues)

      project.update!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
    end

    it 'indexes issues if issues_access_level is updated', :aggregate_failures do
      expect(::Elastic::ProcessBookkeepingService).to receive(:track!)
      expect(::Elastic::ProcessBookkeepingService).to receive(:track!).with(issues)

      project.project_feature.update!(issues_access_level: ProjectFeature::PRIVATE)
    end
  end
end
