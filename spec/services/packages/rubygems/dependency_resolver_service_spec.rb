# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Rubygems::DependencyResolverService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:package) { create(:package, project: project) }
  let(:gem_name) { nil }
  let(:service) { described_class.new(project, user, gem_name: gem_name) }

  describe '#execute' do
    subject { service.execute }

    it 'returns a service error when no package is found' do
      expect(subject.error?).to be(true)
      expect(subject.message).to match(/not found/)
    end

    context 'package without dependencies' do
      let(:gem_name) { package.name }

      it 'returns an empty dependencies array' do
        expected_result = {
          platform: described_class::DEFAULT_PLATFORM,
          dependencies: [],
          name: package.name,
          number: package.version
        }

        expect(subject.payload).to eq(expected_result)
      end
    end

    context 'package with dependencies' do
      let_it_be(:dependency_link) { create(:packages_dependency_link, :rubygems, package: package)}
      let_it_be(:dependency_link2) { create(:packages_dependency_link, :rubygems, package: package)}
      let_it_be(:dependency_link3) { create(:packages_dependency_link, :rubygems, package: package)}
      let(:gem_name) { package.name }

      it 'returns a set of dependencies' do
        expected_result = {
          platform: described_class::DEFAULT_PLATFORM,
          dependencies: [
            [dependency_link.dependency.name, dependency_link.dependency.version_pattern],
            [dependency_link2.dependency.name, dependency_link2.dependency.version_pattern],
            [dependency_link3.dependency.name, dependency_link3.dependency.version_pattern]
          ],
          name: package.name,
          number: package.version
        }

        expect(subject.payload).to eq(expected_result)
      end
    end
  end
end
