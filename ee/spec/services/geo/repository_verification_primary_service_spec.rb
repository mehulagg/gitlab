require 'spec_helper'

describe Geo::RepositoryVerificationPrimaryService do
  let(:project) { create(:project) }
  let(:repository) { double(checksum: 'f123') }
  let(:wiki) { double(checksum: 'e321') }

  subject(:service) { described_class.new(project) }

  describe '#perform' do
    it 'calculates the checksum for unverified projects' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      subject.execute

      expect(project.repository_state).to have_attributes(
        repository_verification_checksum: 'f123',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: 'e321',
        last_wiki_verification_failure: nil
      )
    end

    it 'calculates the checksum for outdated projects' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      repository_state =
        create(:repository_state,
          project: project,
          repository_verification_checksum: nil,
          wiki_verification_checksum: nil)

      subject.execute

      expect(repository_state.reload).to have_attributes(
        repository_verification_checksum: 'f123',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: 'e321',
        last_wiki_verification_failure: nil
      )
    end

    it 'calculates the checksum for outdated repositories/wikis' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      repository_state =
        create(:repository_state,
          project: project,
          repository_verification_checksum: nil,
          wiki_verification_checksum: nil)

      subject.execute

      expect(repository_state.reload).to have_attributes(
        repository_verification_checksum: 'f123',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: 'e321',
        last_wiki_verification_failure: nil
      )
    end

    it 'recalculates the checksum for projects up to date' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      create(:repository_state,
        project: project,
        repository_verification_checksum: 'f079a831cab27bcda7d81cd9b48296d0c3dd92ee',
        wiki_verification_checksum: 'e079a831cab27bcda7d81cd9b48296d0c3dd92ef')

      expect(repository).to receive(:checksum)
      expect(wiki).to receive(:checksum)

      subject.execute
    end

    it 'calculates the wiki checksum even when wiki is not enabled for project' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      project.update!(wiki_enabled: false)

      subject.execute

      expect(project.repository_state).to have_attributes(
        repository_verification_checksum: 'f123',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: 'e321',
        last_wiki_verification_failure: nil
      )
    end

    it 'does not mark the calculating as failed when there is no repo' do
      subject.execute

      expect(project.repository_state).to have_attributes(
        repository_verification_checksum: '0000000000000000000000000000000000000000',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: '0000000000000000000000000000000000000000',
        last_wiki_verification_failure: nil
      )
    end

    it 'does not mark the calculating as failed for non-valid repo' do
      project_broken_repo = create(:project, :broken_repo)

      service = described_class.new(project_broken_repo)
      service.execute

      expect(project_broken_repo.repository_state).to have_attributes(
        repository_verification_checksum: '0000000000000000000000000000000000000000',
        last_repository_verification_failure: nil,
        wiki_verification_checksum: '0000000000000000000000000000000000000000',
        last_wiki_verification_failure: nil
      )
    end

    it 'keeps track of failures when calculating the repository checksum' do
      stub_project_repository(project, repository)
      stub_wiki_repository(project.wiki, wiki)

      allow(repository).to receive(:checksum).and_raise('Something went wrong with repository')
      allow(wiki).to receive(:checksum).twice.and_raise('Something went wrong with wiki')

      subject.execute

      expect(project.repository_state).to have_attributes(
        repository_verification_checksum: nil,
        last_repository_verification_failure: 'Something went wrong with repository',
        wiki_verification_checksum: nil,
        last_wiki_verification_failure: 'Something went wrong with wiki'
      )
    end
  end

  def stub_project_repository(project, repository)
    allow(Repository).to receive(:new).with(
      project.full_path,
      project,
      disk_path: project.disk_path
    ).and_return(repository)
  end

  def stub_wiki_repository(wiki, repository)
    allow(Repository).to receive(:new).with(
      project.wiki.full_path,
      project,
      disk_path: project.wiki.disk_path,
      is_wiki: true
    ).and_return(repository)
  end
end
