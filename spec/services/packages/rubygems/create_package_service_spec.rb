# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Rubygems::CreatePackageService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:params) { {} }

  describe '#execute' do
    subject { described_class.new(project, user, params).execute }

    let(:package) { Packages::Package.last }

    it 'creates the package' do
      expect { subject }.to change { Packages::Package.count }.by(1)

      expect(package).to be_valid
      expect(package.name).to eq(Packages::Rubygems::CreatePackageService::TEMPORARY_PACKAGE_NAME)
      expect(package.version).to start_with(Packages::Rubygems::CreatePackageService::PACKAGE_VERSION)
      expect(package.package_type).to eq('rubygems')
    end

    it 'can create two packages in a row' do
      expect { subject }.to change { Packages::Package.count }.by(1)
      expect { described_class.new(project, user, params).execute }.to change { Packages::Package.count }.by(1)

      expect(package).to be_valid
      expect(package.name).to eq(Packages::Rubygems::CreatePackageService::TEMPORARY_PACKAGE_NAME)
      expect(package.version).to start_with(Packages::Rubygems::CreatePackageService::PACKAGE_VERSION)
      expect(package.package_type).to eq('rubygems')
    end

    it_behaves_like 'assigns the package creator'
    it_behaves_like 'assigns build to package'
  end
end
