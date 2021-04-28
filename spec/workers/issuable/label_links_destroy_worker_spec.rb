# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issuable::LabelLinksDestroyWorker do
  let(:job_args) { [1, 'MergeRequest'] }

  it 'calls the Issuable::DestroyLabelLinksService' do
    expect_next_instance_of(::Issuable::DestroyLabelLinksService, *job_args) do |service|
      expect(service).to receive(:execute)
    end

    described_class.new.perform(*job_args)
  end
end
