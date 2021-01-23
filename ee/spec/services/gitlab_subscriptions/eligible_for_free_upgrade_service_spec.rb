# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::EligibleForFreeUpgradeService do
  subject(:execute) { described_class.new(namespace_id: namespace_id).execute }

  let(:namespace_id) { '111' }

  describe '#execute' do
    using RSpec::Parameterized::TableSyntax

    where(:success, :eligible, :result) do
      true  | true  | true
      true  | false | false
      false | true  | false
      false | false | false
    end

    with_them do
      let(:response) { { success: success, eligible_for_free_upgrade: eligible } }

      before do
        allow(Gitlab::SubscriptionPortal::Client).to receive(:eligible_for_upgrade_offer).and_return(response)
      end

      it 'returns success: true' do
        expect(execute).to eq(result)
      end
    end
  end
end
