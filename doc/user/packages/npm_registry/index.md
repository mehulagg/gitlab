---
stage: Package
group: Package
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# NPM packages in the Package Registry

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/5934) in [GitLab Premium](https://about.gitlab.com/pricing/) 11.7.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/221259) to GitLab Core in 13.3.

Publish NPM packages in your project’s Package Registry. Then install the
packages whenever you need to use them as a dependency.

Only [scoped](https://docs.npmjs.com/misc/scope) packages are supported.

## Build an NPM package

This section covers how to install NPM (or Yarn) and build a package for your
JavaScript project.

If you already use NPM and know how to build your own packages, go to
the [next section](#authenticating-to-the-gitlab-npm-registry).

### Install NPM

Install Node.js and NPM in your local development environment by following
the instructions at [npmjs.com](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm).

When installation is complete, verify you can use NPM in your terminal by
running:

```shell
npm --version
```

The NPM version is printed in the output:

```plaintext
6.10.3
```

### Install Yarn

You may want to install and use Yarn as an alternative to NPM. Follow the
instructions at [yarnpkg.com](https://classic.yarnpkg.com/en/docs/install) to install on
your development environment.

When Yarn is installed, verify you can use Yarn in your terminal by
running:

```shell
yarn --version
```

The Yarn version is printed in the output:

```plaintext
1.19.1
```

### Create a project

To create a project:

1. Create an empty direcotry.
1. Go to the directory and initialize an empty package by running:

   ```shell
   npm init
   ```

   Or if you're using Yarn:

   ```shell
   yarn init
   ```

1. Enter responses to the questions. Ensure the **package name** follows
   the [naming convention](#package-naming-convention) and is scoped to the
   project or group where the registry exists.

A `package.json` file is created. 

## Authenticate to the Package Registry

To authenticate to the Package Registry, you must use one of the following:

- A [personal access token](../../../user/profile/personal_access_tokens.md)
  (required for two-factor authentication (2FA)), with the scope set to `api`.
- A [deploy token](./../../project/deploy_tokens/index.md), with the scope set to `read_package_registry`, `write_package_registry`, or both.
- It's not recommended, but you can use [OAuth tokens](../../../api/oauth2.md#resource-owner-password-credentials-flow).
  Standard OAuth tokens cannot authenticate to the GitLab NPM Registry. You must use a personal access token with OAuth headers.

### Authenticate with a personal access token or deploy token

To authenticate with a [personal access token](../../profile/personal_access_tokens.md) or [deploy token](../../project/deploy_tokens/index.md),
set your NPM configuration:

```shell
# Set URL for your scoped packages
# For example, a package named `@foo/bar` uses this URL for download
npm config set @foo:registry https://gitlab.example.com/api/v4/packages/npm/

# Add the token for the scoped packages URL 
# Use this to download `@foo/` packages from private projects
npm config set '//gitlab.example.com/api/v4/packages/npm/:_authToken' "<your_token>"

# Add token for to publish to the package registry
# Replace <your_project_id> with the project you want to publish your package to
npm config set '//gitlab.example.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken' "<your_token>"
```

- `<your_project_id>` is your project ID, found on the project's home page.
- `<your_token>` is your personal access token or deploy token.
- Replace `gitlab.example.com` with your domain name.

You should now be able to publish and install NPM packages in your project.

If you encounter an error message with [Yarn](https://classic.yarnpkg.com/en/), see the
[troubleshooting section](#troubleshooting).

### Authenticate with a CI job token

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/9104) in GitLab Premium 12.5.
> - [Moved](https://gitlab.com/gitlab-org/gitlab/-/issues/221259) to GitLab Core in 13.3.

If you’re using NPM with GitLab CI/CD, a CI job token can be used instead of a personal access token or deploy token.
The token inherits the permissions of the user that generates the pipeline.

Add a corresponding section to your `.npmrc` file:

```ini
@foo:registry=https://gitlab.com/api/v4/packages/npm/
//gitlab.com/api/v4/packages/npm/:_authToken=${CI_JOB_TOKEN}
//gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}
```

#### Use variables to avoid hard-coding auth token values

To avoid hard-coding the `authToken` value, you may use a variable in its place:

```shell
npm config set '//gitlab.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken' "${NPM_TOKEN}"
npm config set '//gitlab.com/api/v4/packages/npm/:_authToken' "${NPM_TOKEN}"
```

Then, you can run `npm publish` either locally or by using GitLab CI/CD.

- **Locally:** Export `NPM_TOKEN` before publishing:

  ```shell
  NPM_TOKEN=<your_token> npm publish
  ```

- **GitLab CI/CD:** Set an `NPM_TOKEN` [variable](../../../ci/variables/README.md)
  under your project's **Settings > CI/CD > Variables**.

## Publish an NPM package

Before you can publish a package, you must specify the registry
for NPM. To do this, add the following section to the bottom of `package.json`:

```json
"publishConfig": {
  "@foo:registry":"https://gitlab.example.com/api/v4/projects/<your_project_id>/packages/npm/"
}
```

- `<your_project_id>` is your project ID, found on the project's home page.
- `@foo` is your scope.
- Replace `gitlab.example.com` with your domain name.

After you have enabled it and set up [authentication](#authenticate-to-the-gitlab-npm-registry),
you can upload an NPM package to your project:

```shell
npm publish
```

To view the package, to your project's **Packages & Registries**.

If you try to publish a package with a name that already exists within
a given scope, you get a `403 Forbidden!` error.

## Publish an NPM package by using CI/CD

To work with NPM commands within [GitLab CI/CD](./../../../ci/README.md), you can use
`CI_JOB_TOKEN` in place of the personal access token or deploy token in your commands.

An example `.gitlab-ci.yml` file for publishing NPM packages:

```yaml
image: node:latest

stages:
  - deploy

deploy:
  stage: deploy
  script:
    - echo "//gitlab.com/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}">.npmrc
    - npm publish
```

## Publish a package with the same version twice

You cannot upload a package with the same name and version twice, unless you
delete the existing package first. This aligns with npmjs.org's behavior, with
the exception that npmjs.org does not allow users to ever publish the same version
more than once, even if it has been deleted.

## Package naming convention

**Packages must be scoped in the root namespace of the project**. The package
name may be anything but it is preferred that the project name be used unless
it is not possible due to a naming collision. For example:

| Project                | Package                 | Supported |
| ---------------------- | ----------------------- | --------- |
| `foo/bar`              | `@foo/bar`              | Yes       |
| `foo/bar/baz`          | `@foo/baz`              | Yes       |
| `foo/bar/buz`          | `@foo/anything`         | Yes       |
| `gitlab-org/gitlab`    | `@gitlab-org/gitlab`    | Yes       |
| `gitlab-org/gitlab`    | `@foo/bar`              | No        |

The regex that is used for naming is validating all package names from all package managers:

```plaintext
/\A\@?(([\w\-\.\+]*)\/)*([\w\-\.]+)@?(([\w\-\.\+]*)\/)*([\w\-\.]*)\z/
```

It allows for capital letters, while NPM does not, and allows for almost all of the
characters NPM allows with a few exceptions (`~` is not allowed).

NOTE: **Note:**
Capital letters are needed because the scope is required to be
identical to the top level namespace of the project. So, for example, if your
project path is `My-Group/project-foo`, your package must be named `@My-Group/any-package-name`.
`@my-group/any-package-name` will not work.

CAUTION: **When updating the path of a user/group or transferring a (sub)group/project:**
Make sure to remove any NPM packages first. You cannot update the root namespace of a project with NPM packages. Don't forget to update your `.npmrc` files to follow the above naming convention and run `npm publish` if necessary.

Now, you can configure your project to authenticate with the GitLab NPM
Registry.

## Install a package

NPM packages are commonly installed using the `npm` or `yarn` commands
inside a JavaScript project. If you haven't already, set the
URL for scoped packages. You can do this with the following command:

```shell
npm config set @foo:registry https://gitlab.com/api/v4/packages/npm/
```

Replace `@foo` with your scope.

Next, you need to ensure [authentication](#authenticating-to-the-gitlab-npm-registry)
is setup so you can successfully install the package. Once this has been
completed, you can run the following command inside your project to install a
package:

```shell
npm install @my-project-scope/my-package
```

Or if you're using Yarn:

```shell
yarn add @my-project-scope/my-package
```

### Forward requests to npmjs.org

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/55344) in [GitLab Premium](https://about.gitlab.com/pricing/) 12.9.

By default, when an NPM package is not found in the GitLab NPM Registry, the request is forwarded to [npmjs.com](https://www.npmjs.com/).

Administrators can disable this behavior in the [Continuous Integration settings](../../admin_area/settings/continuous_integration.md).

### Install NPM packages from other organizations

You can route package requests to organizations and users outside of GitLab.

To do this, add lines to your `.npmrc` file, replacing `my-org` with the namespace or group that owns your project's repository. The name is case-sensitive and must match the name of your group or namespace exactly.

```shell
@foo:registry=https://gitlab.example.com/api/v4/packages/npm/
//gitlab.com/api/v4/packages/npm/:_authToken= "<your_token>"
//gitlab.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken= "<your_token>"

@my-other-org:registry=https://gitlab.example.com/api/v4/packages/npm/
//gitlab.com/api/v4/packages/npm/:_authToken= "<your_token>"
//gitlab.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken= "<your_token>"
```

## Remove a package

In the packages view of your project page, you can delete packages by clicking
the red trash icons or by clicking the **Delete** button on the package details
page.

Learn more about [using `CI_JOB_TOKEN` to authenticate to the GitLab NPM registry](#authenticating-with-a-ci-job-token).

## Troubleshooting

### Error running Yarn with NPM registry

If you are using [Yarn](https://classic.yarnpkg.com/en/) with the NPM registry, you may get
an error message like:

```shell
yarn install v1.15.2
warning package.json: No license field
info No lockfile found.
warning XXX: No license field
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
error An unexpected error occurred: "https://gitlab.com/api/v4/projects/XXX/packages/npm/XXX/XXX/-/XXX/XXX-X.X.X.tgz: Request failed \"404 Not Found\"".
info If you think this is a bug, please open a bug report with the information provided in "/Users/XXX/gitlab-migration/module-util/yarn-error.log".
info Visit https://classic.yarnpkg.com/en/docs/cli/install for documentation about this command
```

In this case, try adding this to your `.npmrc` file (and replace `<your_token>`
with your personal access token or deploy token):

```plaintext
//gitlab.com/api/v4/projects/:_authToken=<your_token>
```

You can also use `yarn config` instead of `npm config` when setting your auth-token dynamically:

```shell
yarn config set '//gitlab.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken' "<your_token>"
yarn config set '//gitlab.com/api/v4/packages/npm/:_authToken' "<your_token>"
```

### `npm publish` targets default NPM registry (`registry.npmjs.org`)

Ensure that your package scope is set consistently in your `package.json` and `.npmrc` files.

For example, if your project name in GitLab is `foo/my-package`, then your `package.json` file
should look like:

```json
{
  "name": "@foo/my-package",
  "version": "1.0.0",
  "description": "Example package for GitLab NPM registry",
  "publishConfig": {
    "@foo:registry":"https://gitlab.com/api/v4/projects/<your_project_id>/packages/npm/"
  }
}
```

And the `.npmrc` file should look like:

```ini
//gitlab.com/api/v4/projects/<your_project_id>/packages/npm/:_authToken=<your_token>
//gitlab.com/api/v4/packages/npm/:_authToken=<your_token>
@foo:registry=https://gitlab.com/api/v4/packages/npm/
```

### `npm install` returns `Error: Failed to replace env in config: ${NPM_TOKEN}`

You do not need a token to run `npm install` unless your project is private (the token is only required to publish). If the `.npmrc` file was checked in with a reference to `$NPM_TOKEN`, you can remove it. If you prefer to leave the reference in, you need to set a value prior to running `npm install` or set the value using [GitLab environment variables](./../../../ci/variables/README.md):

```shell
NPM_TOKEN=<your_token> npm install
```

### `npm install` returns `npm ERR! 403 Forbidden`

- Check that your token is not expired and has appropriate permissions.
- Check that [your token does not begin with `-`](https://gitlab.com/gitlab-org/gitlab/-/issues/235473).
- Check if you have attempted to publish a package with a name that already exists within a given scope.
- Ensure the scoped packages URL includes a trailing slash:
  - Correct: `//gitlab.com/api/v4/packages/npm/`
  - Incorrect: `//gitlab.com/api/v4/packages/npm`

## NPM dependencies metadata

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/11867) in GitLab Premium 12.6.

Starting from GitLab 12.6, new packages published to the GitLab NPM Registry expose the following attributes to the NPM client:

- name
- version
- dist-tags
- dependencies
  - dependencies
  - devDependencies
  - bundleDependencies
  - peerDependencies
  - deprecated

## NPM distribution tags

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/9425) in GitLab Premium 12.8.

You can add [distribution tags](https://docs.npmjs.com/cli/dist-tag) for newly published packages.
They follow NPM's convention where they are optional, and each tag can only be assigned to one
package at a time. The `latest` tag is added by default when a package is published without a tag.
The same applies to installing a package without specifying the tag or version.

Examples of the supported `dist-tag` commands and using tags in general:

```shell
npm publish @scope/package --tag               # Publish new package with new tag
npm dist-tag add @scope/package@version my-tag # Add a tag to an existing package
npm dist-tag ls @scope/package                 # List all tags under the package
npm dist-tag rm @scope/package@version my-tag  # Delete a tag from the package
npm install @scope/package@my-tag              # Install a specific tag
```

You cannot use your `CI_JOB_TOKEN` or deploy token with the `npm dist-tag` commands.
View [this issue](https://gitlab.com/gitlab-org/gitlab/-/issues/258835) for details.

Due to a bug in NPM 6.9.0, deleting dist tags fails. Make sure your NPM version is greater than 6.9.1.
