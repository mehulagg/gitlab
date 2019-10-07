# frozen_string_literal: true
FactoryBot.define do
  factory :package, class: Packages::Package do
    project
    name { 'my/company/app/my-app' }
    version { '1.0-SNAPSHOT' }
    package_type { 'maven' }

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
      sequence(:name) { |n| "@#{project.root_namespace.path}/package-#{n}"}
      version { '1.0.0' }
      package_type { 'npm' }

      after :create do |package|
        create :package_file, :npm, package: package
      end
    end

    factory :conan_package do
      sequence(:name) { |n| "package-#{n}/1.0.0@#{project.full_path.tr('/', '+')}/stable"}
      version { '1.0.0' }
      package_type { 'conan' }

      after :create do |package|
        create :conan_package_file, :conan_recipe_file, package: package
        create :conan_package_file, :conan_recipe_manifest, package: package
        create :conan_package_file, :conan_package_info, package: package
        create :conan_package_file, :conan_package_manifest, package: package
        create :conan_package_file, :conan_package, package: package
      end
    end
  end

  factory :package_file, class: Packages::PackageFile do
    package

    factory :conan_package_file do
      trait(:conan_recipe_file) do
        after :create do |package_file|
          create :conan_file_metadatum, :recipe_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/recipe_conanfile.py') }
        file_name { 'recipe_conanfile.py' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        file_type { 'py' }
        size { 400.kilobytes }
      end

      trait(:conan_recipe_manifest) do
        after :create do |package_file|
          create :conan_file_metadatum, :recipe_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/recipe_conanmanifest.txt') }
        file_name { 'recipe_conanmanifest.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        file_type { 'txt' }
        size { 400.kilobytes }
      end

      trait(:conan_package_manifest) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/package_conanmanifest.txt') }
        file_name { 'package_conanmanifest.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        file_type { 'txt' }
        size { 400.kilobytes }
      end

      trait(:conan_package_info) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/package_conaninfo.txt') }
        file_name { 'package_conaninfo.txt' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        file_type { 'txt' }
        size { 400.kilobytes }
      end

      trait(:conan_package) do
        after :create do |package_file|
          create :conan_file_metadatum, :package_file, package_file: package_file
        end

        file { fixture_file_upload('ee/spec/fixtures/conan/conan_package.tgz') }
        file_name { 'conan_package.tgz' }
        file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
        file_md5 { '12345abcde' }
        file_type { 'tgz' }
        size { 400.kilobytes }
      end
    end

    trait(:jar) do
      file { fixture_file_upload('ee/spec/fixtures/maven/my-app-1.0-20180724.124855-1.jar') }
      file_name { 'my-app-1.0-20180724.124855-1.jar' }
      file_sha1 { '4f0bfa298744d505383fbb57c554d4f5c12d88b3' }
      file_type { 'jar' }
      size { 100.kilobytes }
    end

    trait(:pom) do
      file { fixture_file_upload('ee/spec/fixtures/maven/my-app-1.0-20180724.124855-1.pom') }
      file_name { 'my-app-1.0-20180724.124855-1.pom' }
      file_sha1 { '19c975abd49e5102ca6c74a619f21e0cf0351c57' }
      file_type { 'pom' }
      size { 200.kilobytes }
    end

    trait(:xml) do
      file { fixture_file_upload('ee/spec/fixtures/maven/maven-metadata.xml') }
      file_name { 'maven-metadata.xml' }
      file_sha1 { '42b1bdc80de64953b6876f5a8c644f20204011b0' }
      file_type { 'xml' }
      size { 300.kilobytes }
    end

    trait(:npm) do
      file { fixture_file_upload('ee/spec/fixtures/npm/foo-1.0.1.tgz') }
      file_name { 'foo-1.0.1.tgz' }
      file_sha1 { 'be93151dc23ac34a82752444556fe79b32c7a1ad' }
      file_type { 'tgz' }
      size { 400.kilobytes }
    end

    trait :object_storage do
      file_store { Packages::PackageFileUploader::Store::REMOTE }
    end
  end

  factory :maven_metadatum, class: Packages::MavenMetadatum do
    package
    path { 'my/company/app/my-app/1.0-SNAPSHOT' }
    app_group { 'my.company.app' }
    app_name { 'my-app' }
    app_version { '1.0-SNAPSHOT' }
  end

  factory :conan_file_metadatum, class: Packages::ConanFileMetadatum do
    package_file
    path { '0/export' }
    revision { '0' }

    trait(:recipe_file) do
      path { '0/export' }
    end
    trait(:package_file) do
      path { '0/package/123456789/0' }
    end
  end
end
