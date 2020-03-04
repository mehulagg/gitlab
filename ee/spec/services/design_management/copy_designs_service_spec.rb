# frozen_string_literal: true
require 'spec_helper'

describe DesignManagement::CopyDesignsService do
  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:design) { create(:design, :with_lfs_file, versions_count: 3, issue: issue, project: project)}
  let_it_be(:note) { create(:diff_note_on_design, noteable: design, project: project) }
  let_it_be(:user) { create(:user) }
  let(:to_issue) { create(:issue) }
  let(:to_repository) { to_issue.project.design_repository }
  let(:run_service) { described_class.new(project, user, issue: issue, to_issue: to_issue).execute }

  # shared_examples 'a service error' do
  #   it 'returns an error', :aggregate_failures do
  #     expect(response).to match(a_hash_including(status: :error))
  #   end
  # end

  # shared_examples 'an execution error' do
  #   it 'returns an error', :aggregate_failures do
  #     expect { service.execute }.to raise_error(some_error)
  #   end
  # end

  # test deletions
  # test updates

  before do
    stub_licensed_features(design_management: true)
    project.add_reporter(user)
  end

  describe '#execute' do
    context 'when the user is not authorized' do
      # before do
      #   project.add_developer(user)
      # end

      # it_behaves_like 'a service error'
      it { skip }
    end

    context 'when the user can copy the issue' do
      before do
        to_issue.project.add_reporter(user)
      end

      it 'copies Designs correctly', :aggregate_failures do
        expect { run_service }.to change { to_issue.designs.count }.from(0).to(1)

        new_design = to_issue.designs.first

        expect(new_design).to have_attributes(
          filename: design.filename,
          issue: to_issue,
          project: to_issue.project
        )
      end

      it 'copies Versions correctly', :aggregate_failures do
        expect { run_service }.to change { to_issue.design_versions.count }.from(0).to(3)

        old_versions = issue.design_versions.ordered
        new_versions = to_issue.design_versions.ordered

        expect(new_versions.count).to eq(old_versions.count)

        new_versions.reload.each_with_index do |version, i|
          old_version = old_versions[i]

          expect(version.designs.pluck(:filename)).to contain_exactly(*old_version.designs.pluck(:filename))
          expect(version.actions.pluck(:event)).to contain_exactly(*old_version.actions.pluck(:event))
        end
      end

      it 'preserves Version created_at timestamps' do
        created_ats = design.versions.map(&:created_at)

        Timecop.freeze(1.hour.from_now) { run_service }

        expect(to_issue.design_versions.map(&:created_at)).to contain_exactly(*created_ats)
      end

      it 'copies the Actions correctly', :aggregate_failures do
        expect { run_service }.to change { DesignManagement::Action.count }.by(3)

        old_actions = issue.design_versions.ordered.flat_map(&:actions)
        new_actions = to_issue.design_versions.ordered.flat_map(&:actions)

        expect(new_actions.count).to eq(old_actions.count)

        new_actions.each_with_index do |action, i|
          old_action = old_actions[i]

          expect(action.event).to eq(old_action.event)
          expect(action.design.filename).to eq(old_action.design.filename)
          # The only way to identify if the versions linked to the actions
          # are correct is to compare design filenames
          expect(action.version.designs.pluck(:filename)).to eq(old_action.version.designs.pluck(:filename))
        end
      end

      it 'links the LfsObjects' do
        # Should be 3 if I can get factories right...
        expect { run_service }.to change { to_issue.project.lfs_objects.count }.from(0).to(1)
      end

      it 'creates a design Repository' do
        expect { run_service }.to change { to_repository.exists? }.from(false).to(true)
      end

      it 'copies the Git repository data' do
        to_repository.create_if_not_exists

        expect { run_service }.to change {
          to_repository.commits('master', limit: 99).size
        }.from(0).to(3)
      end

      it 'sets a commit description' do
        run_service

        expect(to_repository.commit.message).to eq(
          "Copy commit #{project.design_repository.commit.id} from issue #{issue.to_reference(full: true)}"
        )
      end

      it 'copies notes correctly', :aggregate_failures do
        run_service
        new_note = to_issue.designs.first.notes.first

        # The old note should still exist
        expect(design.notes).to contain_exactly(note)
        expect(new_note).to have_attributes(
          type: note.type,
          author_id: note.author_id,
          note: note.note,
          position: note.position
        )
      end

      describe 'query performance' do
        let_it_be(:second_to_issue) { create(:issue) }
        let(:run_second_service) { described_class.new(project, user, issue: issue, to_issue: second_to_issue).execute }

        # Create an additional design with a note
        def create_additional_data
          new_design = create(:design, :with_lfs_file, versions_count: 3, issue: issue, project: project)
          create(:diff_note_on_design, noteable: new_design, project: project)
        end

        it 'avoids N+1 database issues' do
          control_count = ActiveRecord::QueryRecorder.new { run_service }.count
          create_additional_data

          expect { run_second_service }.not_to exceed_query_limit(control_count)
        end

        it 'avoids N+1 Gitaly issues', :request_store do
          Gitlab::GitalyClient.reset_counts
          run_service
          control_count = Gitlab::GitalyClient.get_request_count
          create_additional_data

          expect { run_second_service }
            .to change { Gitlab::GitalyClient.get_request_count }.by_at_most(control_count)
        end
      end

      it 'rollback scenarios'
    end
  end

  describe 'Alert if schema changes', :aggregate_failures do
    let_it_be(:config_file) { Rails.root.join('ee/lib/gitlab/design_management/copy_designs_attributes.yml') }
    let_it_be(:config) { YAML.load_file(config_file).symbolize_keys }

    %w(Design Action Version).each do |model|
      specify {
        attributes = config["#{model.downcase}_attributes".to_sym] || []
        ignored_attributes = config["ignore_#{model.downcase}_attributes".to_sym]

        expect(attributes + ignored_attributes).to contain_exactly(
          *DesignManagement.const_get(model).column_names
        ), failure_message(model)
      }
    end

    def failure_message(model)
      <<-MSG
      The schema of the `#{model}` model has changed.

      `DesignManagement::CopyDesignsService` refers to specific lists of attributes of `#{model}` to either
      copy or ignore, so that we continue to copy designs correctly after schema changes.

      Please update:
      #{config_file}
      to reflect the latest changes to `#{model}`. See that file for more information.
      MSG
    end
  end
end
