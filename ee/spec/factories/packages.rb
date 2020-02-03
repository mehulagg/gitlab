# frozen_string_literal: true
FactoryBot.define do
  factory :package, class: 'Packages::Package' do
    project
    name { 'my/company/app/my-app' }
    sequence(:version) { |n| "1.#{n}-SNAPSHOT" }
    package_type { :maven }

    factory :maven_package do
      maven_metadatum

      after :build do |package|
        package.maven_metadatum.path = "#{package.name}/#{package.version}"
      end

      after :create do |package|
        create :package_file, :xml, package: package
        create :package_file, :jar, package: package
        create :package_file, :pom, package: package
      end
    end

    factory :npm_package do
      sequence(:name) { |n| "@#{project.root_namespace.path}/package-#{n}" }
      version { '1.0.0' }
      package_type { :npm }

      after :create do |package|
        create :package_file, :npm, package: package
      end

      trait :with_build do
        after :create do |package|
          user = package.project.creator
          pipeline = create(:ci_pipeline, user: user)
          create(:ci_build, user: user, pipeline: pipeline)
          create :package_build_info, package: package, pipeline: pipeline
        end
      end
    end

    factory :nuget_package do
      sequence(:name) { |n| "NugetPackage#{n}"}
      sequence(:version) { |n| "1.0.#{n}" }
      package_type { :nuget }

      after :create do |package|
        create :package_file, :nuget, package: package, file_name: "#{package.name}.#{package.version}.nupkg"
      end
    end

    factory :composer_package do
      composer_metadatum

      name { "ochorocho/gitlab-composer" }
      version { '2.0.0' }
      package_type { :composer }

      after :create do |package|
        create :package_file, :composer, package: package
      end
    end

    factory :conan_package do
      conan_metadatum

      after :build do |package|
        package.conan_metadatum.package_username = Packages::ConanMetadatum.package_username_from(
          full_path: package.project.full_path
        )
      end

      sequence(:name) { |n| "package-#{n}" }
      version { '1.0.0' }
      package_type { :conan }

      after :create do |package|
        create :conan_package_file, :conan_recipe_file, package: package
        create :conan_package_file, :conan_recipe_manifest, package: package
        create :conan_package_file, :conan_package_info, package: package
        create :conan_package_file, :conan_package_manifest, package: package
        create :conan_package_file, :conan_package, package: package
      end

      trait(:without_loaded_metadatum) do
        conan_metadatum { build(:conan_metadatum, package: nil) }
      end
    end
  end

  factory :package_build_info, class: 'Packages::BuildInfo' do
  end

  factory :package_file, class: 'Packages::PackageFile' do
    package

    factory :conan_package_file do
      trait(:conan_recipe_file) do
        after :create do |package_file|
          create :conan_file_metadatum, :recipe_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/recipe_files/conanfile.py') }
        file_name { 'conanfile.py' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        size { 400.kilobytes }
      end

      trait(:conan_recipe_manifest) do
        after :create do |package_file|
          create :conan_file_metadatum, :recipe_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/recipe_files/conanmanifest.txt') }
        file_name { 'conanmanifest.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        size { 400.kilobytes }
      end

      trait(:conan_package_manifest) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/package_files/conanmanifest.txt') }
        file_name { 'conanmanifest.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        size { 400.kilobytes }
      end

      trait(:conan_package_info) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/package_files/conaninfo.txt') }
        file_name { 'conaninfo.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        size { 400.kilobytes }
      end

      trait(:conan_package) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/package_files/conan_package.tgz') }
        file_name { 'conan_package.tgz' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        size { 400.kilobytes }
      end
    end

    trait(:jar) do
      file { fixture_file_upload('ee/spec/fixtures/maven/my-app-1.0-20180724.124855-1.jar') }
      file_name { 'my-app-1.0-20180724.124855-1.jar' }
      file_sha1 { '4f0bfa298744d505383fbb57c554d4f5c12d88b3' }
      size { 100.kilobytes }
    end

    trait(:pom) do
      file { fixture_file_upload('ee/spec/fixtures/maven/my-app-1.0-20180724.124855-1.pom') }
      file_name { 'my-app-1.0-20180724.124855-1.pom' }
      file_sha1 { '19c975abd49e5102ca6c74a619f21e0cf0351c57' }
      size { 200.kilobytes }
    end

    trait(:xml) do
      file { fixture_file_upload('ee/spec/fixtures/maven/maven-metadata.xml') }
      file_name { 'maven-metadata.xml' }
      file_sha1 { '42b1bdc80de64953b6876f5a8c644f20204011b0' }
      size { 300.kilobytes }
    end

    trait(:npm) do
      file { fixture_file_upload('ee/spec/fixtures/npm/foo-1.0.1.tgz') }
      file_name { 'foo-1.0.1.tgz' }
      file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
      size { 400.kilobytes }
    end

    trait(:nuget) do
      package
      file { fixture_file_upload('ee/spec/fixtures/nuget/package.nupkg') }
      file_name { 'package.nupkg' }
      file_sha1 { '5fe852b2a6abd96c22c11fa1ff2fb19d9ce58b57' }
      size { 300.kilobytes }
    end

    trait(:composer) do
      file { fixture_file_upload('ee/spec/fixtures/composer/ochorocho-gitlab-composer-2.0.0-19c3ec.tar') }
      file_name { 'ochorocho-gitlab-composer-2.0.0-19c3ec.tar' }
      file_sha1 { 'c775f1f5cc34f272e25c17b62e1932d0ca5087f8' }
    end

    trait :object_storage do
      file_store { Packages::PackageFileUploader::Store::REMOTE }
    end
  end

  factory :maven_metadatum, class: 'Packages::MavenMetadatum' do
    association :package, package_type: :maven
    path { 'my/company/app/my-app/1.0-SNAPSHOT' }
    app_group { 'my.company.app' }
    app_name { 'my-app' }
    app_version { '1.0-SNAPSHOT' }
  end

  factory :conan_metadatum, class: 'Packages::ConanMetadatum' do
    association :package, factory: [:conan_package, :without_loaded_metadatum]
    package_username { 'username' }
    package_channel { 'stable' }
  end

  factory :conan_file_metadatum, class: 'Packages::ConanFileMetadatum' do
    package_file
    recipe_revision { '0' }

    trait(:recipe_file) do
      conan_file_type { 'recipe_file' }
    end

    trait(:package_file) do
      conan_file_type { 'package_file' }
      package_revision { '0' }
      conan_package_reference { '123456789' }
    end
  end

  factory :packages_dependency, class: 'Packages::Dependency' do
    sequence(:name) { |n| "@test/package-#{n}"}
    sequence(:version_pattern) { |n| "~6.2.#{n}" }
  end

  factory :packages_dependency_link, class: 'Packages::DependencyLink' do
    package
    dependency { create(:packages_dependency) }
    dependency_type { :dependencies }
  end

  factory :packages_tag, class: 'Packages::Tag' do
    package
    sequence(:name) { |n| "tag-#{n}"}
  end

  factory :composer_metadatum, class: 'Packages::ComposerMetadatum' do
    association :package, package_type: :composer
    name { 'ochorocho/gitlab-composer' }
    version { '2.0.0' }
    json { JSON.parse(File.read('ee/spec/fixtures/api/schemas/public_api/v4/packages/composer_package_version.json')) }
  end
end
