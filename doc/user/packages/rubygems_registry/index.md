---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Ruby gems in the Package Registry

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/803) in [GitLab Free](https://about.gitlab.com/pricing/) 13.10.

Publish Ruby gems in your project’s Package Registry. Then install the
packages whenever you need to use them as a dependency.

## Create a Ruby Gem

This section explains how to create a gem.

If you already use RubyGems and know how to build your own packages, go to the
[next section](#authenticate-with-the-package-registry).

### Create a project

Create a test project.

1. Open your terminal.
1. Create a directory called `my_gem`, and then go to that directory:

   ```shell
   mkdir my_gem && cd my_gem
   ```

1. Create a directory called `lib` and inside of that directory create a file named `my_gem.rb`

   ```shell
   mkdir lib
   touch lib/my_gem.rb
   ```

1. Add some contents to `my_gem.rb`:

   ```shell
   class MyGem
      def self.hello
        puts "Hello GitLab!"
      end
    end
   ```

1. Create a `.gemspec` file named `my_gem.gemspec` in the `my_gem/` directory.

   ```shell
   touch my_gem.gemspec
   ```

1. Define your gem inside of that file:

   ```ruby
   Gem::Specification.new do |s|
     s.name        = 'my_gem'
     s.version     = '0.0.1'
     s.summary     = "Hello GitLab!"
     s.description = "A simple hello world gem"
     s.authors     = ["GitLab Tanuki"]
     s.email       = 'tanuki@gitlab.com'
     s.files       = ["lib/my_gem.rb"]
     s.license     = 'MIT'
   end
   ```

See the [RubyGems specification reference](https://guides.rubygems.org/specification-reference/)
for details on available attributes.

Now that you have a project put together with a `.gemspec` file, you are ready
to build a gem!

### Build the gem

After you create a project, you can create a gem.

1. In your terminal, go to the `my_gem` directory.

1. Build the gem from the `.gemspec` file:

   ```shell
   gem build my_gem.gemspec
   ```

The output should be visible in `my_gem` directory:

```shell
ls -1
```

You should see the newly created `.gem` file listed:

```plaintext
lib
my_gem-1.0.0.gem
my_gem.gemspec
```

The gem is now ready to be published to the Package Registry.

## Authenticate with the Package Registry

Before you can publish to the Package Registry, you must authenticate.

To do this, you can use:

- A [personal access token](../../../user/profile/personal_access_tokens.md)
  with the scope set to `api`.
- A [deploy token](../../project/deploy_tokens/index.md) with the scope set to
  `read_package_registry`, `write_package_registry`, or both.
- A [CI job token](#authenticate-with-a-ci-job-token).

### Authenticate with a personal access token or deploy token

To authenticate with a personal access token, create or edit the `~/.gem/credentials` file and add:

```ini
---
https://gitlab.example.com/api/v4/projects/<project_id>/packages/rubygems: '<your token>'
```

- `<your token>` must be the token value of either your personal access token or deploy token.
- Your project ID is on your project's home page.

### Authenticate with a CI job token

To work with RubyGems commands within [GitLab CI/CD](../../../ci/README.md), you
can use `CI_JOB_TOKEN` instead of a personal access token or deploy token.

For example:

```yaml
image: ruby:latest

run:
  script:
```

You can also use `CI_JOB_TOKEN` in a `~/.gem/credentials` file that you check in to
GitLab:

```ini
---
https://gitlab.example.com/api/v4/projects/${env.CI_PROJECT_ID}/packages/rubygems: '${env.CI_JOB_TOKEN}'
```

## Publish a Ruby gem

Prerequisites:

- You must [authenticate with the Package Registry](#authenticate-with-the-package-registry).
- Your [version string must be valid](#ensure-your-version-string-is-valid).
- The maximum allowed gem size is 3 GB.
- You can't upload the same version of a gem multiple times. If you try,
  you receive the error `400 Bad Request`.
- You cannot publish your gem to a group, only to a project.

To publish your gem, run a command like:

```shell
gem push my_gem-0.0.1.gem --host <host>
```

- `<host>` is the URL you used when setting up authentication, for example:

```shell
gem push my_gem-0.0.1.gem --host https://gitlab.example.com/api/v4/projects/1/packages/rubygems
```

This message indicates that the package was published successfully:

```plaintext
Pushing gem to https://gitlab.example.com/api/v4/projects/1/packages/rubygems...
{"message":"201 Created"}
```

To view the published gem, go to your project's **Packages & Registries**
page. When publishing gems to GitLab, they aren't displayed in the packages user
interface of your project immediately. It can take up to 10 minutes to process
a gem.

### Publishing packages with the same name or version

You cannot publish a package if a package of the same name and version already exists.
You must delete the existing package first. If you attempt to publish the same package
more than once, a `401 Bad Request` error occurs.

## Install a Ruby gem

### Using gem install

To install the latest version of a package, use the following command:

```shell
gem install my_gem --source <source>
```

- `<source>` is the URL you used when setting up authentication, for example:

```shell
gem install my_gem --source https://gitlab.example.com/api/v4/projects/1/packages/rubygems
```

### Using bundler

Add the gem to your project's Gemfile:

```plaintext
source 'https://gitlab.example.com/api/v4/projects/1/packages/rubygems'

gem 'my_gem'
```

Run `bundle install` from the directory containing the Gemfile:

```shell
bundle install
```
