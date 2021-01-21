# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OpenIssuesCountService, :use_clean_rails_memory_store_caching do
  let(:project) { create(:project) }

  describe '#count' do
    it 'does not count test cases' do
      create(:issue, :opened, project: project)
      create(:incident, :opened, project: project)
      create(:quality_test_case, :opened, project: project)

      expect(described_class.new(project).count).to eq(2)
    end
  end
end
