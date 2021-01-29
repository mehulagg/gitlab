# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Key do
  describe 'validations' do
    describe 'expiration' do
      using RSpec::Parameterized::TableSyntax

      where(:key, :expiration_enforced, :valid ) do
        build(:personal_key, expires_at: 2.days.ago) | true | false
        build(:personal_key, expires_at: 2.days.ago) | false | true
        build(:personal_key) | false | true
        build(:personal_key) | true | true
      end

      with_them do
        it 'checks if ssh key expiration is enforced' do
          expect(Key).to receive(:expiration_enforced?).and_return(expiration_enforced)

          expect(key.valid?).to eq(valid)
        end
      end
    end
  end

  describe '.expiration_enforced?' do
    using RSpec::Parameterized::TableSyntax

    where(:feature_enabled, :licensed, :application_setting, :available) do
      true  | true  | true  | true
      true  | true  | false | false
      true  | false | true  | false
      true  | false | false | false
      false | true  | true  | false
      false | true  | false | false
      false | false | true  | false
      false | false | false | false
    end

    with_them do
      before do
        stub_feature_flags(ff_enforce_ssh_key_expiration: feature_enabled)
        stub_licensed_features(enforce_ssh_key_expiration: licensed)
        stub_ee_application_setting(enforce_ssh_key_expiration: application_setting)
      end

      it 'checks if ssh key expiration is enforced' do
        expect(described_class.expiration_enforced?).to be(available)
      end
    end
  end
end
