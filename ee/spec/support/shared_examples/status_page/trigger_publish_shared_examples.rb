# frozen_string_literal: true

# This shared_example requires the following variables:
# - execute: Executes the service
# - issue_id: The issue id to be published
# - project: The project related to published issue
# - user: The user who triggers the publish
#
# Usage:
#
#   include_examples 'trigger status page publish' do
#     let(:execute) { service.execute }
#     let(:issue_id) { execute.id }
#   end
RSpec.shared_examples 'trigger status page publish' do
  include_context 'status page enabled'

  it 'triggers status page publish' do
    allow(StatusPage::PublishWorker)
      .to receive(:perform_async)
      .with(user.id, project.id, kind_of(Integer))

    execute

    expect(StatusPage::PublishWorker)
      .to have_received(:perform_async)
      .with(user.id, project.id, issue_id)
  end
end

# This shared_example requires the following variables:
# - execute: Executes the service
# - project: The project related to published issue
# - user: The user who triggers the publish
#
# Usage:
#
#   include_examples 'no trigger status page publish' do
#     let(:execute) { service.execute }
#   end
RSpec.shared_examples 'no trigger status page publish' do
  include_context 'status page enabled'

  it 'does not trigger status page publish service' do
    expect(StatusPage::PublishWorker).not_to receive(:perform_async)

    execute
  end
end
