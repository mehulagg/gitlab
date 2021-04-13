# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProfilesHelper do
  before do
    allow(Key).to receive(:enforce_ssh_key_expiration_feature_available?).and_return(true)
  end

  describe "#ssh_key_expiration_tooltip" do
    using RSpec::Parameterized::TableSyntax

    error_message = 'Key type is forbidden. Must be DSA, ECDSA, or ED25519'

    where(:error, :expired, :enforced, :result) do
      false | false | false | nil
      true  | false | false | error_message
      true  | false | true  | error_message
      true  | true  | false | error_message
      true  | true  | true  | 'Invalid key.'
      false | true  | true  | 'Expired key is not valid.'
      false | true  | false | 'Key usable beyond expiration date.'
    end

    with_them do
      let_it_be(:key) { build(:personal_key) }

      it do
        allow(Key).to receive(:expiration_enforced?).and_return(enforced)
        key.expires_at = expired ? 2.days.ago : 2.days.from_now
        key.errors.add(:base, error_message) if error

        expect(helper.ssh_key_expiration_tooltip(key)).to eq(result)
      end
    end

    context 'when enforced and expired' do
      let_it_be(:key) { build(:personal_key) }

      it 'does not return the expiration validation error message', :aggregate_failures do
        allow(Key).to receive(:expiration_enforced?).and_return(true)
        key.expires_at = 2.days.ago

        expect(key.invalid?).to eq(true)
        expect(helper.ssh_key_expiration_tooltip(key)).to eq('Expired key is not valid.')
      end
    end
  end

  describe "#ssh_key_expires_field_description" do
    using RSpec::Parameterized::TableSyntax

    where(:expiration_enforced, :result) do
      true  | "Key will be deleted on this date."
      false | "Key can still be used after expiration."
    end

    with_them do
      it do
        allow(Key).to receive(:expiration_enforced?).and_return(expiration_enforced)

        expect(helper.ssh_key_expires_field_description).to eq(result)
      end
    end
  end
end
