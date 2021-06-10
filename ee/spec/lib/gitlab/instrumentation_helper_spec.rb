# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::InstrumentationHelper do
  describe '.add_instrumentation_data', :request_store do
    let(:payload) { {} }

    subject { described_class.add_instrumentation_data(payload) }

    # We don't want to interact with Elasticsearch in GitLab FOSS so we test
    # this in ee/ only. The code exists in FOSS and won't do anything.
    context 'when Elasticsearch calls are made', :elastic do
      it 'adds Elasticsearch data' do
        ensure_elasticsearch_index!

        subject

        expect(payload[:elasticsearch_calls]).to be > 0
        expect(payload[:elasticsearch_duration_s]).to be > 0
        expect(payload[:elasticsearch_timed_out_count]).to be_kind_of(Integer)
      end
    end
  end
end
