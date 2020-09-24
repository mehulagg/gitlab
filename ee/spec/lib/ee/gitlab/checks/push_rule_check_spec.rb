# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Checks::PushRuleCheck do
  include_context 'push rules checks context'

  let(:push_rule) { create(:push_rule, :commit_message) }

  describe '#validate!' do
    before do
      expect_any_instance_of(EE::Gitlab::Checks::PushRules::FileSizeCheck)
        .to receive(:validate!)
    end

    context 'when tag name exists' do
      before do
        allow(change_access).to receive(:tag_name).and_return(true)
      end

      it 'validates tags push rules' do
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::TagCheck)
          .to receive(:validate!)
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::BranchCheck)
          .not_to receive(:validate!)

        subject.validate!
      end
    end

    context 'when tag name does not exists' do
      before do
        allow(change_access).to receive(:tag_name).and_return(false)
      end

      it 'validates branches push rules' do
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::TagCheck)
          .not_to receive(:validate!)
        expect_any_instance_of(EE::Gitlab::Checks::PushRules::BranchCheck)
          .to receive(:validate!)

        subject.validate!
      end
    end
  end
end
