# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dast::Profile, type: :model do
  let_it_be(:project) { create(:project) }

  subject { create(:dast_profile, project: project) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:dast_site_profile) }
    it { is_expected.to belong_to(:dast_scanner_profile) }
    it { is_expected.to have_many(:secret_variables).through(:dast_site_profile).class_name('Dast::SiteProfileSecretVariable') }
    it { is_expected.to have_many(:dast_profiles_pipelines).class_name('Dast::ProfilesPipeline').with_foreign_key(:dast_profile_id).inverse_of(:dast_profile) }
    it { is_expected.to have_many(:ci_pipelines).through(:dast_profiles_pipelines).class_name('Ci::Pipeline') }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_most(255) }
    it { is_expected.to validate_length_of(:branch_name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { is_expected.to validate_presence_of(:project_id) }
    it { is_expected.to validate_presence_of(:dast_site_profile_id) }
    it { is_expected.to validate_presence_of(:dast_scanner_profile_id) }
    it { is_expected.to validate_presence_of(:name) }

    context 'when the project_id and dast_site_profile.project_id do not match' do
      let(:dast_site_profile) { create(:dast_site_profile) }

      subject { build(:dast_profile, project: project, dast_site_profile: dast_site_profile) }

      it 'is not valid' do
        aggregate_failures do
          expect(subject.valid?).to be_falsey
          expect(subject.errors.full_messages).to include('Project must match dast_site_profile.project_id')
        end
      end
    end

    context 'when the project_id and dast_scanner_profile.project_id do not match' do
      let(:dast_scanner_profile) { create(:dast_scanner_profile) }

      subject { build(:dast_profile, project: project, dast_scanner_profile: dast_scanner_profile) }

      it 'is not valid' do
        aggregate_failures do
          expect(subject.valid?).to be_falsey
          expect(subject.errors.full_messages).to include('Project must match dast_scanner_profile.project_id')
        end
      end
    end

    context 'when the description is nil' do
      subject { build(:dast_profile, description: nil) }

      it 'is not valid' do
        aggregate_failures do
          expect(subject.valid?).to be_falsey
          expect(subject.errors.full_messages).to include('Description can\'t be nil')
        end
      end
    end
  end

  describe 'scopes' do
    describe 'by_project_id' do
      it 'includes the correct records' do
        another_dast_profile = create(:dast_profile)

        result = described_class.by_project_id(subject.project_id)

        aggregate_failures do
          expect(result).to include(subject)
          expect(result).not_to include(another_dast_profile)
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#branch' do
      context 'when the associated project does not have a repository' do
        it 'returns nil' do
          expect(subject.branch).to be_nil
        end
      end

      context 'when the associated project has a repository' do
        let_it_be(:project) { create(:project, :repository) }

        subject { create(:dast_profile, project: project) }

        it 'returns a Dast::Branch' do
          expect(subject.branch).to be_a(Dast::Branch)
        end
      end
    end

    describe '#ci_variables' do
      context 'when there are no secret_variables' do
        it 'returns an empty collection' do
          expect(subject.ci_variables.size).to be_zero
        end
      end

      context 'when there are secret_variables' do
        it 'returns a collection containing that variable' do
          variable = create(:dast_site_profile_secret_variable, dast_site_profile: subject.dast_site_profile)

          expect(subject.ci_variables.to_runner_variables).to include(key: variable.key, value: variable.value, public: false, masked: true)
        end
      end
    end
  end
end
