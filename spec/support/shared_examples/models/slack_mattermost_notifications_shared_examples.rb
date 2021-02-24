# frozen_string_literal: true

RSpec.shared_examples 'slack or mattermost notifications' do |service_name|
  include StubRequests

  let(:chat_service) { described_class.new }
  let(:webhook_url) { 'https://example.gitlab.com' }

  def execute_with_options(options)
    receive(:new).with(webhook_url, options.merge(http_client: SlackMattermost::Notifier::HTTPClient))
     .and_return(double(:slack_service).as_null_object)
  end

  describe "Associations" do
    it { is_expected.to belong_to :project }
    it { is_expected.to have_one :service_hook }
  end

  describe 'Validations' do
    context 'when service is active' do
      before do
        subject.active = true
      end

      it { is_expected.to validate_presence_of(:webhook) }
      it_behaves_like 'issue tracker service URL attribute', :webhook
    end

    context 'when service is inactive' do
      before do
        subject.active = false
      end

      it { is_expected.not_to validate_presence_of(:webhook) }
    end
  end

  shared_examples "triggered #{service_name} service" do |event_type: nil, branches_to_be_notified: nil|
    before do
      chat_service.branches_to_be_notified = branches_to_be_notified if branches_to_be_notified
    end

    let!(:stubbed_resolved_hostname) do
      stub_full_request(webhook_url, method: :post).request_pattern.uri_pattern.to_s
    end

    it "notifies about #{event_type} events" do
      chat_service.execute(data)
      expect(WebMock).to have_requested(:post, stubbed_resolved_hostname)
    end
  end

  shared_examples "untriggered #{service_name} service" do |event_type: nil, branches_to_be_notified: nil|
    before do
      chat_service.branches_to_be_notified = branches_to_be_notified if branches_to_be_notified
    end

    let!(:stubbed_resolved_hostname) do
      stub_full_request(webhook_url, method: :post).request_pattern.uri_pattern.to_s
    end

    it "notifies about #{event_type} events" do
      chat_service.execute(data)
      expect(WebMock).not_to have_requested(:post, stubbed_resolved_hostname)
    end
  end

  describe "#execute" do
    let_it_be(:project) { create(:project, :repository, :wiki_repo) }
    let_it_be(:user) { create(:user).freeze }

    let(:data) { Gitlab::DataBuilder::Push.build_sample(project, user) }

    let!(:stubbed_resolved_hostname) do
      stub_full_request(webhook_url, method: :post).request_pattern.uri_pattern.to_s
    end

    subject { chat_service.execute(data) }

    before do
      allow(chat_service).to receive_messages(
        project: project,
        project_id: project.id,
        service_hook: true,
        webhook: webhook_url
      )
    end

    context 'with username for slack configured' do
      let(:chat_service) { described_class.new(username: 'slack_username', branches_to_be_notified: 'all') }

      it 'uses the username as an option' do
        expect(Slack::Messenger).to execute_with_options(username: 'slack_username')

        subject
      end
    end

    context 'push events' do
      let(:data) { Gitlab::DataBuilder::Push.build_sample(project, user) }

      it "calls #{service_name} API for push events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end

      context 'whith event channel' do
        let(:chat_service) { described_class.new(push_channel: 'random', branches_to_be_notified: 'all') }

        it 'uses the right channel for push event' do
          expect(Slack::Messenger).to execute_with_options(channel: ['random'])

          subject
        end
      end
    end

    context 'issue events' do
      let_it_be(:issue) { create(:issue) }
      let(:data) { issue.to_hook_data(user) }

      it "calls #{service_name} API for issue events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end

      context 'whith event channel' do
        let(:chat_service) { described_class.new(issue_channel: 'random') }

        it 'uses the right channel for issue event' do
          expect(Slack::Messenger).to execute_with_options(channel: ['random'])

          subject
        end

        context 'for confidential issues' do
          let_it_be(:issue) { create(:issue, confidential: true) }

          it 'falls back to issue channel' do
            expect(Slack::Messenger).to execute_with_options(channel: ['random'])

            subject
          end

          context 'and confidential_issue_channel is defined' do
            let(:chat_service) { described_class.new(issue_channel: 'random', confidential_issue_channel: 'confidential') }

            it 'uses the confidential issue channel when it is defined' do
              expect(Slack::Messenger).to execute_with_options(channel: ['confidential'])

              subject
            end
          end
        end
      end
    end

    context 'merge request events' do
      let_it_be(:merge_request) { create(:merge_request) }
      let(:data) { merge_request.to_hook_data(user) }

      it "calls #{service_name} API for merge requests events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end

      context 'with event channel' do
        let(:chat_service) { described_class.new(merge_request_channel: 'random') }

        it 'uses the right channel for merge request event' do
          expect(Slack::Messenger).to execute_with_options(channel: ['random'])

          subject
        end
      end
    end

    context 'wiki page events' do
      let_it_be(:wiki_page) { create(:wiki_page, wiki: project.wiki, message: 'user created page: Awesome wiki_page') }
      let(:data) { Gitlab::DataBuilder::WikiPage.build(wiki_page, user, 'create') }

      it "calls #{service_name} API for wiki page events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end

      context 'with event channel' do
        let(:chat_service) { described_class.new(wiki_page_channel: 'random') }

        it 'uses the right channel for wiki event' do
          expect(Slack::Messenger).to execute_with_options(channel: ['random'])

          subject
        end
      end
    end

    context 'deployment events' do
      let_it_be(:deployment) { create(:deployment) }
      let(:data) { Gitlab::DataBuilder::Deployment.build(deployment) }

      it "calls #{service_name} API for deployment events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end
    end

    context 'note event' do
      let_it_be(:issue_note) { create(:note_on_issue, project: project, note: "issue note") }
      let(:data) { Gitlab::DataBuilder::Note.build(issue_note, user) }

      it "calls #{service_name} API for note events" do
        subject

        expect(WebMock).to have_requested(:post, stubbed_resolved_hostname).once
      end

      context 'with event channel' do
        let(:chat_service) { described_class.new(note_channel: 'random') }

        it 'uses the right channel' do
          expect(Slack::Messenger).to execute_with_options(channel: ['random'])

          subject
        end

        context 'for confidential notes' do
          let(:issue_note) { create(:note_on_issue, project: project, note: 'issue note', confidential: true) }

          it 'falls back to note channel' do
            expect(Slack::Messenger).to execute_with_options(channel: ['random'])

            subject
          end

          context 'and confidential_note_channel is defined' do
            let(:chat_service) { described_class.new(issue_channel: 'random', confidential_note_channel: 'confidential') }

            it 'uses confidential channel' do
              expect(Slack::Messenger).to execute_with_options(channel: ['confidential'])

              chat_service.execute(data)
            end
          end
        end
      end
    end
  end

  describe 'Push events' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :repository, creator: user) }

    before do
      allow(chat_service).to receive_messages(
        project: project,
        service_hook: true,
        webhook: webhook_url
      )

      stub_full_request(webhook_url, method: :post)
    end

    context 'on default branch' do
      let(:data) do
        Gitlab::DataBuilder::Push.build(
          project: project,
          user: user,
          ref: project.default_branch
        )
      end

      context 'pushing tags' do
        let(:data) do
          Gitlab::DataBuilder::Push.build(
            project: project,
            user: user,
            ref: "#{Gitlab::Git::TAG_REF_PREFIX}test"
          )
        end

        it_behaves_like "triggered #{service_name} service", event_type: "push"
      end

      context 'notification enabled only for default branch' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "default"
      end

      context 'notification enabled only for protected branches' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "protected"
      end

      context 'notification enabled only for default and protected branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "default_and_protected"
      end

      context 'notification enabled for all branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "all"
      end
    end

    context 'on a protected branch' do
      before do
        create(:protected_branch, project: project, name: 'a-protected-branch')
      end

      let(:data) do
        Gitlab::DataBuilder::Push.build(
          project: project,
          user: user,
          ref: 'a-protected-branch'
        )
      end

      context 'pushing tags' do
        let(:data) do
          Gitlab::DataBuilder::Push.build(
            project: project,
            user: user,
            ref: "#{Gitlab::Git::TAG_REF_PREFIX}test"
          )
        end

        it_behaves_like "triggered #{service_name} service", event_type: "push"
      end

      context 'notification enabled only for default branch' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "default"
      end

      context 'notification enabled only for protected branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "protected"
      end

      context 'notification enabled only for default and protected branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "default_and_protected"
      end

      context 'notification enabled for all branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "all"
      end
    end

    context 'on a protected branch with protected branches defined using wildcards' do
      before do
        create(:protected_branch, project: project, name: '*-stable')
      end

      let(:data) do
        Gitlab::DataBuilder::Push.build(
          project: project,
          user: user,
          ref: '1-stable'
        )
      end

      context 'pushing tags' do
        let(:data) do
          Gitlab::DataBuilder::Push.build(
            project: project,
            user: user,
            ref: "#{Gitlab::Git::TAG_REF_PREFIX}test"
          )
        end

        it_behaves_like "triggered #{service_name} service", event_type: "push"
      end

      context 'notification enabled only for default branch' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "default"
      end

      context 'notification enabled only for protected branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "protected"
      end

      context 'notification enabled only for default and protected branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "default_and_protected"
      end

      context 'notification enabled for all branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "all"
      end
    end

    context 'on a neither protected nor default branch' do
      let(:data) do
        Gitlab::DataBuilder::Push.build(
          project: project,
          user: user,
          ref: 'a-random-branch'
        )
      end

      context 'pushing tags' do
        let(:data) do
          Gitlab::DataBuilder::Push.build(
            project: project,
            user: user,
            ref: "#{Gitlab::Git::TAG_REF_PREFIX}test"
          )
        end

        it_behaves_like "triggered #{service_name} service", event_type: "push"
      end

      context 'notification enabled only for default branch' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "default"
      end

      context 'notification enabled only for protected branches' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "protected"
      end

      context 'notification enabled only for default and protected branches' do
        it_behaves_like "untriggered #{service_name} service", event_type: "push", branches_to_be_notified: "default_and_protected"
      end

      context 'notification enabled for all branches' do
        it_behaves_like "triggered #{service_name} service", event_type: "push", branches_to_be_notified: "all"
      end
    end
  end

  describe 'Note events' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :repository, creator: user) }

    before do
      allow(chat_service).to receive_messages(
        project: project,
        service_hook: true,
        webhook: webhook_url
      )

      stub_full_request(webhook_url, method: :post)
    end

    context 'when commit comment event executed' do
      let(:commit_note) do
        create(:note_on_commit, author: user,
                                project: project,
                                commit_id: project.repository.commit.id,
                                note: 'a comment on a commit')
      end

      let(:data) do
        Gitlab::DataBuilder::Note.build(commit_note, user)
      end

      it_behaves_like "triggered #{service_name} service", event_type: "commit comment"
    end

    context 'when merge request comment event executed' do
      let(:merge_request_note) do
        create(:note_on_merge_request, project: project,
                                       note: 'a comment on a merge request')
      end

      let(:data) do
        Gitlab::DataBuilder::Note.build(merge_request_note, user)
      end

      it_behaves_like "triggered #{service_name} service", event_type: "merge request comment"
    end

    context 'when issue comment event executed' do
      let(:issue_note) do
        create(:note_on_issue, project: project,
                               note: 'a comment on an issue')
      end

      let(:data) do
        Gitlab::DataBuilder::Note.build(issue_note, user)
      end

      it_behaves_like "triggered #{service_name} service", event_type: "issue comment"
    end

    context 'when snippet comment event executed' do
      let(:snippet_note) do
        create(:note_on_project_snippet, project: project,
                                         note: 'a comment on a snippet')
      end

      let(:data) do
        Gitlab::DataBuilder::Note.build(snippet_note, user)
      end

      it_behaves_like "triggered #{service_name} service", event_type: "snippet comment"
    end
  end

  describe 'Pipeline events' do
    let(:user) { create(:user) }
    let(:project) { create(:project, :repository, creator: user) }
    let(:pipeline) do
      create(:ci_pipeline,
             project: project, status: status,
             sha: project.commit.sha, ref: project.default_branch)
    end

    before do
      allow(chat_service).to receive_messages(
        project: project,
        service_hook: true,
        webhook: webhook_url
      )

      stub_full_request(webhook_url, method: :post)
    end

    context 'with succeeded pipeline' do
      let(:status) { 'success' }
      let(:data) { Gitlab::DataBuilder::Pipeline.build(pipeline) }

      context 'with default to notify_only_broken_pipelines' do
        it_behaves_like "untriggered #{service_name} service", event_type: "pipeline"
      end

      context 'with setting notify_only_broken_pipelines to false' do
        before do
          chat_service.notify_only_broken_pipelines = false
        end

        it_behaves_like "triggered #{service_name} service", event_type: "pipeline"
      end
    end

    context 'with failed pipeline' do
      context 'on default branch' do
        let(:pipeline) do
          create(:ci_pipeline,
                project: project, status: :failed,
                sha: project.commit.sha, ref: project.default_branch)
        end

        let(:data) { Gitlab::DataBuilder::Pipeline.build(pipeline) }

        context 'notification enabled only for default branch' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default"
        end

        context 'notification enabled only for protected branches' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "protected"
        end

        context 'notification enabled only for default and protected branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default_and_protected"
        end

        context 'notification enabled for all branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "all"
        end
      end

      context 'on a protected branch' do
        before do
          create(:protected_branch, project: project, name: 'a-protected-branch')
        end

        let(:pipeline) do
          create(:ci_pipeline,
                project: project, status: :failed,
                sha: project.commit.sha, ref: 'a-protected-branch')
        end

        let(:data) { Gitlab::DataBuilder::Pipeline.build(pipeline) }

        context 'notification enabled only for default branch' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default"
        end

        context 'notification enabled only for protected branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "protected"
        end

        context 'notification enabled only for default and protected branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default_and_protected"
        end

        context 'notification enabled for all branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "all"
        end
      end

      context 'on a protected branch with protected branches defined usin wildcards' do
        before do
          create(:protected_branch, project: project, name: '*-stable')
        end

        let(:pipeline) do
          create(:ci_pipeline,
                project: project, status: :failed,
                sha: project.commit.sha, ref: '1-stable')
        end

        let(:data) { Gitlab::DataBuilder::Pipeline.build(pipeline) }

        context 'notification enabled only for default branch' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default"
        end

        context 'notification enabled only for protected branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "protected"
        end

        context 'notification enabled only for default and protected branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default_and_protected"
        end

        context 'notification enabled for all branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "all"
        end
      end

      context 'on a neither protected nor default branch' do
        let(:pipeline) do
          create(:ci_pipeline,
                project: project, status: :failed,
                sha: project.commit.sha, ref: 'a-random-branch')
        end

        let(:data) { Gitlab::DataBuilder::Pipeline.build(pipeline) }

        context 'notification enabled only for default branch' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default"
        end

        context 'notification enabled only for protected branches' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "protected"
        end

        context 'notification enabled only for default and protected branches' do
          it_behaves_like "untriggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "default_and_protected"
        end

        context 'notification enabled for all branches' do
          it_behaves_like "triggered #{service_name} service", event_type: "pipeline", branches_to_be_notified: "all"
        end
      end
    end
  end
end
