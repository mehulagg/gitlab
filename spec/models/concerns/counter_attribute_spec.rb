# frozen_string_literal: true

require 'spec_helper'

describe CounterAttribute, :counter_attribute do
  let_it_be(:project) { create(:project) }

  it_behaves_like CounterAttribute, [:counter_a, :counter_b] do
    let!(:subject_1) { TestCounterAttribute.create!(project: project) }
    let!(:subject_2) { TestCounterAttribute.create!(project: project) }
    let!(:subject_3) { TestCounterAttribute.create!(project: project) }

    subject { subject_1 }

    let(:counter_attribute_events_class) { TestCounterAttributeEvent }
    let(:counter_attribute_foreign_key) { 'test_counter_attribute_id' }
  end
end
