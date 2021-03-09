# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::SiteProfileVariable, type: :model do
  subject { create(:dast_site_profile_variable) }

  it_behaves_like 'CI variable'

  describe 'associations' do
    it { is_expected.to belong_to(:dast_site_profile) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to include_module(Ci::Maskable) }
    it { is_expected.to include_module(Ci::NewHasVariable) }
    it { is_expected.to validate_inclusion_of(:masked).in_array([true]) }
    it { is_expected.to validate_uniqueness_of(:key).scoped_to(:dast_site_profile_id).with_message(/\(\w+\) has already been taken/) }

    it 'only onlys records where variablee_type=env_var', :aggregate_failures do
      subject = build(:dast_site_profile_variable, variable_type: :file)

      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include('Variable type is not included in the list')
    end
  end

  describe '#project' do
    it 'delegates to dast_site_profile' do
      expect(subject.project).to eq(subject.dast_site_profile.project)
    end
  end

  describe '#masked' do
    it 'defaults to true' do
      expect(subject.masked).to eq(true)
    end
  end

  describe '#variable_type' do
    it 'defaults to env_var' do
      expect(subject.variable_type).to eq('env_var')
    end
  end

  describe '#raw_value=' do
    it 'pre-encodes the value' do
      value = SecureRandom.hex

      subject = create(:dast_site_profile_variable, raw_value: value)

      expect(Base64.strict_decode64(subject.value)).to eq(value)
    end
  end
end
