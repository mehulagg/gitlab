# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BatchOpenIssuesCountService do
  let!(:project_1) { create(:project) }
  let!(:project_2) { create(:project) }

  let(:subject) { described_class.new([project_1, project_2]) }

  describe '#refresh_cache', :use_clean_rails_memory_store_caching do
    before do
      create(:issue, project: project_1)
      create(:issue, project: project_1, confidential: true)
      create(:issue, project: project_1, hidden: true)

      create(:issue, project: project_2)
      create(:issue, project: project_2, confidential: true)
      create(:issue, project: project_2, hidden: true)
    end

    context 'when cache is clean' do
      it 'refreshes cache keys correctly', :aggregate_failures do
        subject.refresh_cache

        # It does not update total issues cache
        expect(Rails.cache.read(get_cache_key(subject, project_1))).to eq(nil)
        expect(Rails.cache.read(get_cache_key(subject, project_2))).to eq(nil)

        expect(Rails.cache.read(get_cache_key(subject, project_1, true, false))).to eq(2)
        expect(Rails.cache.read(get_cache_key(subject, project_2, true, false))).to eq(2)

        expect(Rails.cache.read(get_cache_key(subject, project_1, true, true))).to eq(3)
        expect(Rails.cache.read(get_cache_key(subject, project_2, true, true))).to eq(3)
      end
    end

    context 'when issues count is already cached' do
      before do
        create(:issue, project: project_2)
        subject.refresh_cache
      end

      it 'does update cache again' do
        expect(Rails.cache).not_to receive(:write)

        subject.refresh_cache
      end
    end
  end

  def get_cache_key(subject, project, include_confidential = false, include_hidden = false)
    service = subject.count_service.new(project)

    if include_confidential
      if include_hidden
        service.cache_key(service.class::TOTAL_COUNT_KEY)
      else
        service.cache_key(service.class::TOTAL_COUNT_WITHOUT_HIDDEN_KEY)
      end
    else
      service.cache_key(service.class::PUBLIC_COUNT_WITHOUT_HIDDEN_KEY)
    end
  end
end
