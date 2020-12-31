# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::InProductMarketingEmailsWorker, '#perform' do
  include AfterNextHelpers

  before do
    stub_const('Namespaces::InProductMarketingEmailsService::TRACKS', [:first_track])
    stub_const('Namespaces::InProductMarketingEmailsService::INTERVALS', [1])
  end

  context 'when the experiment is inactive' do
    before do
      stub_experiment(in_product_marketing_emails: false)
    end

    it 'does not execute the in product marketing emails service' do
      expect_next(Namespaces::InProductMarketingEmailsService).not_to receive(:execute)

      subject.perform
    end
  end

  context 'when the experiment is active' do
    before do
      stub_experiment(in_product_marketing_emails: true)
    end

    it 'initializes and executes the in product marketing emails service with the right parameters' do
      expect_next(Namespaces::InProductMarketingEmailsService, :first_track, 1).to receive(:execute)

      subject.perform
    end
  end
end
