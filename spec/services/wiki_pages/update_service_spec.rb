require 'spec_helper'

describe WikiPages::UpdateService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:page) { create(:wiki_page) }

  let(:opts) do
    {
      content: 'New content for wiki page',
      format: 'markdown',
      message: 'New wiki message',
      title: 'New Title'
    }
  end

  subject(:service) { described_class.new(project, user, opts) }

  before do
    project.add_master(user)
  end

  describe '#execute' do
    it 'updates the wiki page' do
      updated_page = service.execute(page)

      expect(updated_page).to be_valid
      expect(updated_page).to have_attributes(message: opts[:message], content: opts[:content], format: opts[:format].to_sym)

      expect(updated_page.title).to eq(opts[:title])
    end

    it 'executes webhooks' do
      expect(service).to receive(:execute_hooks).once.with(instance_of(WikiPage), 'update')

      service.execute(page)
    end
  end
end
