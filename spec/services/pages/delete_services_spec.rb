# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pages::DeleteService do
  let_it_be(:admin) { create(:admin) }

  let(:project) { create(:project, path: "my.project")}
  let!(:domain) { create(:pages_domain, project: project) }
  let(:service) { described_class.new(project, admin)}

  before do
    project.mark_pages_as_deployed
  end

  it 'deletes published pages' do
    expect(project.pages_deployed?).to be(true)

    expect_any_instance_of(Gitlab::PagesTransfer).to receive(:rename_project).and_return true
    expect(PagesWorker).to receive(:perform_in).with(5.minutes, :remove, project.namespace.full_path, anything)

    Sidekiq::Testing.inline! { service.execute }

    expect(project.pages_deployed?).to be(false)
  end

  it 'deletes all domains' do
    expect(project.pages_domains.count).to eq(1)

    Sidekiq::Testing.inline! { service.execute }

    expect(project.reload.pages_domains.count).to eq(0)
  end

  it 'marks pages as not deployed, deletes domains and schedules worker to remove pages from disk' do
    expect(project.pages_deployed?).to eq(true)
    expect(project.pages_domains.count).to eq(1)

    service.execute

    expect(project.pages_deployed?).to eq(false)
    expect(project.pages_domains.count).to eq(0)

    expect_any_instance_of(Gitlab::PagesTransfer).to receive(:rename_project).and_return true

    Sidekiq::Worker.drain_all
  end
end
