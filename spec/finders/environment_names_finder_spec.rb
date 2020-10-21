# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnvironmentNamesFinder do
  describe '#execute' do
    let!(:group) { create(:group) }
    let!(:project1) { create(:project, :public, namespace: group) }
    let!(:project2) { create(:project, :private, namespace: group) }
    let!(:user) { create(:user) }

    before do
      create(:environment, name: 'gstg', project: project1)
      create(:environment, name: 'gprd', project: project1)
      create(:environment, name: 'gprd', project: project2)
      create(:environment, name: 'gcny', project: project2)
    end

    context 'using a group and a group developer' do
      it 'returns environment names for all projects' do
        group.add_developer(user)

        names = described_class.new(group, user).execute

        expect(names).to eq(%w[gcny gprd gstg])
      end
    end

    context 'using a group and a group reporter' do
      it 'returns environment names for all projects' do
        group.add_reporter(user)

        names = described_class.new(group, user).execute

        expect(names).to eq(%w[gcny gprd gstg])
      end
    end

    context 'using a group and a public project reporter' do
      it 'returns environment names for all projects' do
        project1.add_reporter(user)

        names = described_class.new(group, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a group and a group guest' do
      it 'does not return environment names for private projects' do
        group.add_guest(user)

        names = described_class.new(group, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a group and a non-member' do
      it 'returns environment names for all public projects' do
        names = described_class.new(group, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a group without a user' do
      it 'returns environment names for all public projects' do
        names = described_class.new(group).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a public project and a project developer' do
      it 'returns all the unique environment names' do
        project1.add_developer(user)

        names = described_class.new(project1, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a public project and a project guest' do
      it 'returns all the unique environment names' do
        project1.add_guest(user)

        names = described_class.new(project1, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a public project and a non-member' do
      it 'returns all the unique environment names' do
        names = described_class.new(project1, user).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a private project and a project developer' do
      it 'returns all the unique environment names' do
        project2.add_developer(user)

        names = described_class.new(project2, user).execute

        expect(names).to eq(%w[gcny gprd])
      end
    end

    context 'using a private project and a project reporter' do
      it 'returns all the unique environment names' do
        project2.add_reporter(user)

        names = described_class.new(project2, user).execute

        expect(names).to eq(%w[gcny gprd])
      end
    end

    context 'using a private project and a project guest' do
      it 'returns all the unique environment names' do
        project2.add_guest(user)

        names = described_class.new(project2, user).execute

        expect(names).to be_empty
      end
    end

    context 'using a private project and a non-member' do
      it 'returns all the unique environment names' do
        names = described_class.new(project2, user).execute

        expect(names).to be_empty
      end
    end

    context 'using a public project without a user' do
      it 'returns all the unique environment names' do
        names = described_class.new(project1).execute

        expect(names).to eq(%w[gprd gstg])
      end
    end

    context 'using a private project without a user' do
      it 'does not return any environment names' do
        names = described_class.new(project2).execute

        expect(names).to eq([])
      end
    end
  end
end
