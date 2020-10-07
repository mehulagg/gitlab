---
stage: Create
group: Static Site Editor
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers"
type: reference, how-to
description: "The static site editor enables users to edit content on static websites without prior knowledge of the underlying templating language, site architecture or Git commands."
---

# Static Site Editor

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/28758) in GitLab 12.10.
> - WYSIWYG editor [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/214559) in GitLab 13.0.
> - Support for adding images through the WYSIWYG editor [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/216640) in GitLab 13.1.
> - Markdown front matter hidden on the WYSIWYG editor [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/216834) in GitLab 13.1.
> - Support for `*.md.erb` files [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/223171) in GitLab 13.2.
> - Non-Markdown content blocks uneditable on the WYSIWYG mode [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/216836) in GitLab 13.3.
> - Ability to edit page front matter [introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/235921) in GitLab 13.4.

DANGER: **Danger:**
In GitLab 13.0, we [introduced breaking changes](https://gitlab.com/gitlab-org/gitlab/-/issues/213282)
to the URL structure of the Static Site Editor. Follow the instructions in this
[snippet](https://gitlab.com/gitlab-org/project-templates/static-site-editor-middleman/snippets/1976539)
to update your project with the latest changes.

Static Site Editor enables users to edit content on static websites without
prior knowledge of the underlying templating language, site architecture, or
Git commands. A contributor to your project can quickly edit a Markdown page
and submit the changes for review.

## Use cases

The Static Site Editors allows collaborators to submit changes to static site
files seamlessly. For example:

- Non-technical collaborators can easily edit a page directly from the browser; they don't need to know Git and the details of your project to be able to contribute.
- Recently hired team members can quickly edit content.
- Temporary collaborators can jump from project to project and quickly edit pages instead of having to clone or fork every single project they need to submit changes to.

## Requirements

- In order use the Static Site Editor feature, your project needs to be
pre-configured with the [Static Site Editor Middleman template](https://gitlab.com/gitlab-org/project-templates/static-site-editor-middleman).
- The editor needs to be logged into GitLab and needs to be a member of the
project (with Developer or higher permission levels).

## How it works

The Static Site Editor is in an early stage of development and only works for
Middleman sites for now. You have to use a specific site template to start
using it. The project template is configured to deploy a [Middleman](https://middlemanapp.com/)
static website with [GitLab Pages](../pages/index.md).

Once your website is up and running, you'll see a button **Edit this page** on
the bottom-left corner of its pages:

![Edit this page button](img/edit_this_page_button_v12_10.png)

When you click it, GitLab opens up an editor window from which the content
can be directly edited. When you're ready, you can submit your changes in a
click of a button:

![Static Site Editor](img/wysiwyg_editor_v13_3.png)

You can also edit the page's front matter both in WYSIWYG mode via the side-drawer and in Markdown
mode.

![Editing page front matter in the Static Site Editor](img/front_matter_ui_v13_4.png)

When an editor submits their changes, in the background, GitLab automatically
creates a new branch, commits their changes, and opens a merge request. The
editor lands directly on the merge request, and then they can assign it to
a colleague for review.

## Getting started

First, set up the project. Once done, you can use the Static Site Editor to
easily edit your content.

### Set up your project

1. To get started, create a new project from the
[Static Site Editor - Middleman](https://gitlab.com/gitlab-org/project-templates/static-site-editor-middleman)
template. You can either [fork it](../repository/forking_workflow.md#creating-a-fork)
or [create a new project from a template](../../../gitlab-basics/create-project.md#built-in-templates).
1. Edit the [`data/config.yml`](#static-site-generator-configuration) file, and replace the `<username>` and `<project-name>` with the proper values for your project's path. See ["Static Site Generator Configuration"](#static-site-generator-configuration) for more details.
1. Optionally edit the [`.gitlab/static-site-editor.yml`](#static-site-editor-configuration-file) file. See ["Static Site Editor Configuration File"](#static-site-generator-configuration) for more details.
1. Commiting the edits to these files will trigger a CI/CD pipeline to deploy your project with GitLab Pages.
1. When the pipeline finishes, from your project's left-side menu, go to **Settings > Pages** to find the URL of your new website.
1. Visit your website and look at the bottom-left corner of the screen to see the new **Edit this page** button.

Anyone satisfying the [requirements](#requirements) will be able to edit the
content of the pages without prior knowledge of Git or of your site's
codebase.

NOTE: **Note:**
From GitLab 13.1 onwards, the YAML front matter of Markdown files is hidden on the
WYSIWYG editor to avoid unintended changes. To edit it, use the Markdown editing mode, the regular
GitLab file editor, or the Web IDE.

### Use the Static Site Editor to edit your content

For instance, suppose you are a recently hired technical writer at a large
company and a new feature has been added to the company product.

1. You are assigned the task of updating the documentation.
1. You visit a page and see content that needs to be edited.
1. Click the **Edit this page** button on the production site.
1. The file is opened in the Static Site Editor in **WYSIWYG** mode. If you wish to edit the raw Markdown
   instead, you can toggle the **Markdown** mode in the bottom-right corner.
1. You edit the file right there and click **Submit changes**.
1. A new merge request is automatically created and you assign it to your colleague for review.

## Configuration Files

There are two types of configuration files used to customize the behavior of a project which uses the Static Site Editor.

1. The `.gitlab/static-site-editor.yml` is used to customize the behavior of the Static Site Editor.
1. Static Site Generator Configuration files, such as `data/config.yml`, may be used to customize the "Edit this page" link when the site is generated. 

### Static Site Editor Configuration File

The `.gitlab/static-site-editor.yml` configuration file contains entries which can be used to customize behavior of the Static Site Editor.

If the file does not exist, default values which support a default Middleman project configuration will be used. The [Static Site Editor - Middleman](https://gitlab.com/gitlab-org/project-templates/static-site-editor-middleman) project template generates a file which is pre-populated with these defaults.

The following entries are supported in `.gitlab/static-site-editor.yml`:

#### `static_site_generator`

NOTE: **Note:**
Although Middleman is the only Static Site Generator currently officially supported by the Static Site Editor, you can still use others. See [Static Site Generator Configuration](#static-site-generator-configuration) for more details.

This indicates which Static Site Generator tool is used to generate the site. The only currently supported value is `middleman`.

- Type: String.
- Supported values: `middleman`.
- Default value: `middleman`.

Example:

```yaml
static_site_generator: middleman
```

#### `image_upload_path`

NOTE: **Note:**
Support for uploading images in the Static Site Editor is still in progress, so this entry currently has no effect. 

This indicates the path in which newly uploaded image files will be placed.

- Type: String.
- Supported values: Any path relative to the root of the project. Leading and trailing slashes should not be included.
- Default value: `source/images`.

Example:

```yaml
image_upload_path: source/images
```

#### `mounts`

NOTE: **Note:**
Support for mounts in the Static Site Editor is still in progress, so this entry currently has no effect.

This is an array of `source` + `target` mapping pairs. It allows the mapping of a path relative to the web root to the full repository path, so that images and other files referenced in a page’s source can be properly resolved and rendered in the WYSIWYG editor. This is similar to the [`mounts` config for Hugo](https://gohugo.io/hugo-modules/configuration/#module-config-mounts). 

If the `target` is the top level of the web root, the value may be specified as an empty quoted string.

- Type: An array, with entries consisting of `source` + `target` mapping pairs, which are Strings.
- Supported values:
  - `source`: The path relative to the repository's project root. Leading and trailing slashes should not be included.
  - `target`: Where the content relative to the source should considered to be mounted, relative to the web root. Leading and trailing slashes should not be included.
- Default value:

    ```yaml
      - source: source
        target: ''
    ```

Example:

```yaml
mounts:
  - source: source
    target: ''
  - source: source/images
    target: images
  - source: path/to/a/different/relative/source
    target: different
```

### Static Site Generator Configuration

#### `data/config.yml`

The `data/config.yml` configuration file is used by Middleman in the [layout.erb](https://gitlab.com/gitlab-org/project-templates/static-site-editor-middleman/-/blob/master/source/layouts/layout.erb) to render an "Edit this page" link, which will automatically open the page in the Static Site Editor. In the default version of the file which is created by the Static Site Editor Middleman project template, you must replace the `<username>` and `<project-name>` with the proper values for your project's path.

Other Static Site Generators used with the Static Site Generator may use different configuration files or approaches.

#### Using Other Static Site Generators

Although Middleman is the only Static Site Generator currently officially supported by the Static Site Editor, you still have the option to configure your project's build and deployment to use a different Static Site Generator. In this case, you can use the Middleman layout as an example, and follow a similar approach to properly render an "Edit this page" link in your Static Site Generator's layout.

## Limitations

- The Static Site Editor still cannot be quickly added to existing Middleman sites. Follow this [epic](https://gitlab.com/groups/gitlab-org/-/epics/2784) for updates.
