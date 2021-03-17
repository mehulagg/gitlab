# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::ProfilePipeline, type: :model do
  subject { create(:dast_profile_pipeline) }

  describe 'associations' do
    it { is_expected.to belong_to(:profile).class_name('Dast::Profile').with_foreign_key('dast_profile_id') }
    it { is_expected.to belong_to(:pipeline).class_name('Ci::Pipeline').with_foreign_key('ci_pipeline_id') }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:dast_profile_id) }
    it { is_expected.to validate_presence_of(:ci_pipeline_id) }
  end
end
