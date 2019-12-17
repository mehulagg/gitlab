# frozen_string_literal: true

FactoryBot.define do
  factory :design_version, class: DesignManagement::Version do
    sequence(:sha) { |n| Digest::SHA1.hexdigest("commit-like-#{n}") }
    issue { designs.first&.issue || create(:issue) }
    author { issue.author || create(:user) }

    transient do
      designs_count { 1 }
      created_designs { [] }
      modified_designs { [] }
      deleted_designs { [] }
    end

    # Warning: this will intentionally result in an invalid version!
    trait :empty do
      designs_count { 0 }
    end

    after(:build) do |version, evaluator|
      # By default all designs are created_designs, so just add them.
      specific_designs = [].concat(
        evaluator.created_designs,
        evaluator.modified_designs,
        evaluator.deleted_designs
      )
      version.designs += specific_designs

      unless evaluator.designs_count.zero? || version.designs.present?
        version.designs << create(:design, issue: version.issue)
      end
    end

    after :create do |version, evaluator|
      # FactoryBot does not like methods, so we use lambdas instead
      events = DesignManagement::Action.events

      version.actions
        .where(design_id: evaluator.modified_designs.map(&:id))
        .update_all(event: events[:modification])

      version.actions
        .where(design_id: evaluator.deleted_designs.map(&:id))
        .update_all(event: events[:deletion])

      version.designs.reload
      # Ensure version.issue == design.issue for all version.designs
      version.designs.update_all(issue_id: version.issue_id)

      needed = evaluator.designs_count
      have = version.designs.size

      create_list(:design, [0, needed - have].max, issue: version.issue).each do |d|
        version.designs << d
      end

      version.actions.reset
    end

    # This trait is for versions that must be present in the git repository.
    trait :committed do
      transient do
        file { File.join(Rails.root, 'spec/fixtures/dk.png') }
      end

      after :create do |version, evaluator|
        project = version.issue.project
        repository = project.design_repository
        repository.create_if_not_exists

        designs = version.designs_by_event
        base_change = { content: evaluator.file }

        actions = %w[modification deletion].flat_map { |k| designs.fetch(k, []) }.map do |design|
          base_change.merge(action: :create, file_path: design.full_path)
        end

        if actions.present?
          repository.multi_action(
            evaluator.author,
            branch_name: 'master',
            message: "created #{actions.size} files",
            actions: actions
          )
        end

        mapping = {
          'creation' => :create,
          'modification' => :update,
          'deletion' => :delete
        }

        version_actions = designs.flat_map do |(event, designs)|
          base = event == 'deletion' ? {} : base_change
          designs.map do |design|
            base.merge(action: mapping[event], file_path: design.full_path)
          end
        end

        sha = repository.multi_action(
          evaluator.author,
          branch_name: 'master',
          message: "edited #{version_actions.size} files",
          actions: version_actions
        )

        version.update(sha: sha)
      end
    end
  end
end
