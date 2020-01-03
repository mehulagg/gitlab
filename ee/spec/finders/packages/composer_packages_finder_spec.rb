# frozen_string_literal: true
require 'spec_helper'

describe Packages::ComposerPackagesFinder do
  let(:current_user) { create(:user) }
  let(:group) { create(:group, name: 'ochorocho') }
  let(:project) { create(:project, namespace: group) }
  let!(:package) { create(:composer_package, project: project, name: "#{group.name}/gitlab-composer") }
  let(:current_user_empty) { create(:user) }

  before do
    group.add_developer(current_user)
    project.add_maintainer(current_user)
  end

  describe '#execute!' do
    context 'across all projects' do
      it 'returns instance endpoint packages' do
        finder = described_class.new(current_user)

        expect(finder.execute).to eq([package])
      end

      it 'returns an empty collection' do
        finder = described_class.new(current_user_empty)

        expect(finder.execute).to be_empty
      end
    end

    context 'within a group' do
      it 'returns endpoint packages' do
        finder = described_class.new(current_user, group)

        expect(finder.execute).to eq([package])
      end

      it 'returns an empty collection' do
        finder = described_class.new(current_user_empty, group)

        expect(finder.execute).to be_empty
      end
    end
  end
end
