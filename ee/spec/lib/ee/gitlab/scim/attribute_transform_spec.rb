# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::Scim::AttributeTransform do
  using RSpec::Parameterized::TableSyntax

  describe '#valid?' do
    it 'is true for accepted keys' do
      expect(described_class.new(:userName)).to be_valid
    end

    it 'is false for unused keys' do
      expect(described_class.new(:someUnknownKey)).not_to be_valid
    end
  end

  describe '#gitlab_key' do
    where(:scim_key, :expected) do
      :id | :extern_uid
      :displayName | :name
      'name.formatted' | :name
      'emails[type eq "work"].value' | :email
      :active | :active
      :externalId | :extern_uid
      :userName | :username
    end

    with_them do
      it do
        expect(described_class.new(scim_key).gitlab_key).to eq expected
      end
    end
  end

  describe '#map_to' do
    it 'returns an empty hash for unknown keys' do
      expect(described_class.new(:abc).map_to(double)).to eq({})
    end

    it 'typecasts input' do
      expect(described_class.new(:active).map_to('true')).to eq(active: true)
    end

    it 'creates a hash from transformed key to a typecasted value' do
      expect(described_class.new(:userName).map_to('"my_handle"')).to eq(username: 'my_handle')
    end
  end
end
