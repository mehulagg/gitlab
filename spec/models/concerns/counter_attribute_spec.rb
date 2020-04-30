# frozen_string_literal: true

require 'spec_helper'

describe CounterAttribute do
  class StubProjectStatisticsEvent < ApplicationRecord
    self.table_name = 'project_statistics_events'

    belongs_to :stub_project_statistics, foreign_key: :project_statistics_id
  end

  class StubProjectStatistics < ApplicationRecord
    self.table_name = 'project_statistics'

    belongs_to :project

    include CounterAttribute

    counter_attribute :build_artifacts_size
  end

  it_behaves_like CounterAttribute, [:build_artifacts_size] do
    subject { StubProjectStatistics.find(create(:project_statistics).id) }

    let(:subject_2) { StubProjectStatistics.find(create(:project_statistics).id) }
    let(:subject_3) { StubProjectStatistics.find(create(:project_statistics).id) }

    let(:counter_attribute_events_class) { StubProjectStatisticsEvent }
    let(:counter_attribute_table_name) { 'project_statistics_events' }
    let(:counter_attribute_foreign_key) { 'project_statistics_id' }
  end
end
