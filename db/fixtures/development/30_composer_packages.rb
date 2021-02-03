# frozen_string_literal: true

require './spec/support/sidekiq_middleware'

class Gitlab::Seeder::ComposerPackages
  def group
    @group ||= Group.find_by(path: 'composer')

    unless @group
      @group = Group.create!(
        name: 'Composer',
        path: 'composer',
        description: FFaker::Lorem.sentence
      )

      @group.add_owner(User.first)
      @group.create_namespace_settings
    end

    @group
  end

  def create_real_project!(url)
    project_path = url.split('/').last

    project_path.gsub!(".git", "2")

    project = group.projects.find_by(name: project_path.titleize)

    return project if project.present?

    params = {
      import_url: url,
      namespace_id: group.id,
      name: project_path.titleize,
      description: FFaker::Lorem.sentence,
      visibility_level: Gitlab::VisibilityLevel.values.sample,
      skip_disk_validation: true
    }

    project = nil

    Sidekiq::Worker.skipping_transaction_check do
      project = ::Projects::CreateService.new(User.first, params).execute

      # Seed-Fu runs this entire fixture in a transaction, so the `after_commit`
      # hook won't run until after the fixture is loaded. That is too late
      # since the Sidekiq::Testing block has already exited. Force clearing
      # the `after_commit` queue to ensure the job is run now.
      project.send(:_run_after_commit_queue)
      project.import_state.send(:_run_after_commit_queue)

      # Expire repository cache after import to ensure
      # valid_repo? call below returns a correct answer
      project.repository.expire_all_method_caches
    end

    if project.valid? && project.valid_repo?
      print '.'
      return project
    else
      puts project.errors.full_messages
      print 'F'
      return nil
    end
  end
end

COMPOSER_PACKAGES = {
  'https://github.com/php-fig/log.git' => [
    { branch: "master" },
    { tag: 'v1.5.2' }
  ],
  'https://github.com/ryssbowh/craft-themes.git' => [
    { tag: '2.7.4' }
  ],
  'https://github.com/php-fig/http-message.git' => [
  ],
  'https://github.com/doctrine/instantiator.git' => [
  ]
}.freeze

Gitlab::Seeder.quiet do
  Sidekiq::Testing.inline! do
    COMPOSER_PACKAGES.keys.each do |path|
      project = Gitlab::Seeder::ComposerPackages.new.create_real_project!(path)

         #::Packages::Composer::CreatePackageService
          #  .new(authorized_user_project, User.first, params)
         #   .execute
    end
  end
end
