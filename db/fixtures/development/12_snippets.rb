require './spec/support/sidekiq_middleware'

Gitlab::Seeder.quiet do
  bundle_path = File.join(Rails.root, 'db/fixtures/development/bundles/gitlab-snippet-test.bundle')

  20.times do |i|
    user = User.not_mass_generated.sample

    user.snippets.create({
      type: 'PersonalSnippet',
      title: FFaker::Lorem.sentence(3),
      file_name:  'file.rb',
      visibility_level: Gitlab::VisibilityLevel.values.sample,
      content: 'foo'
    }).tap do |snippet|
      unless snippet.repository_exists?
        snippet.repository.create_from_bundle(bundle_path)
      end

      snippet.track_snippet_repository(snippet.repository.storage)
      snippet.statistics.refresh!
    end

    print('.')
  end
end

