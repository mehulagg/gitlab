---
stage: none
group: Style Guide
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
description: 'Writing styles, markup, formatting, and other standards for GitLab Documentation.'
---

# Documentation Style Guide: Markdown syntax

All GitLab documentation is written using [Markdown](https://en.wikipedia.org/wiki/Markdown).
This document defines the standards for using Markdown in GitLab's documentation content and
files.

The [documentation website](https://docs.gitlab.com) uses GitLab Kramdown as its
Markdown rendering engine. For a complete Kramdown reference, see the
[GitLab Markdown Kramdown Guide](https://about.gitlab.com/handbook/markdown-guide/).

The [`gitlab-kramdown`](https://gitlab.com/gitlab-org/gitlab_kramdown) Ruby gem
will support all [GFM markup](../../user/markdown.md) in the future, which is
all markup supported for display in the GitLab application itself. For now, use
regular Markdown markup, following the rules in the linked style guide.

Note that Kramdown-specific markup (for example, `{:.class}`) doesn't render
properly on GitLab instances under [`/help`](index.md#gitlab-help).

## HTML in Markdown

Hard-coded HTML is valid, although it's discouraged from being used while we
have `/help`. HTML is permitted if:

- There's no equivalent markup in Markdown.
- Advanced tables are necessary.
- Special styling is required.
- Reviewed and approved by a technical writer.

## Markdown rules

GitLab ensures that the Markdown used across all documentation is consistent, as
well as easy to review and maintain, by [testing documentation changes](index.md#testing)
with [markdownlint](index.md#markdownlint). This lint test fails when any
document has an issue with Markdown formatting that may cause the page to render
incorrectly within GitLab. It will also fail when a document is using
non-standard Markdown (which may render correctly, but is not the current
standard for GitLab documentation).

### Markdown rule `MD044/proper-names` (capitalization)

A rule that could cause confusion is `MD044/proper-names`, as it might not be
immediately clear what caused markdownlint to fail, or how to correct the
failure. This rule checks a list of known words, listed in the `.markdownlint.json`
file in each project, to verify proper use of capitalization and backticks.
Words in backticks will be ignored by markdownlint.

In general, product names should follow the exact capitalization of the official
names of the products, protocols, and so on. See [`.markdownlint.json`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/.markdownlint.json)
for the words tested for proper capitalization in GitLab documentation.

Some examples fail if incorrect capitalization is used:

- MinIO (needs capital `IO`)
- NGINX (needs all capitals)
- runit (needs lowercase `r`)

Additionally, commands, parameters, values, filenames, and so on must be
included in backticks. For example:

- "Change the `needs` keyword in your `.gitlab.yml`..."
  - `needs` is a parameter, and `.gitlab.yml` is a file, so both need backticks.
    Additionally, `.gitlab.yml` will fail markdownlint without backticks as it
    does not have capital G or L.
- "Run `git clone` to clone a Git repository..."
  - `git clone` is a command, so it must be lowercase, while Git is the product,
    so it must have a capital G.

## Text

- [Write in Markdown](#markdown).
- Splitting long lines (preferably up to 100 characters) can make it easier to
  provide feedback on small chunks of text.
- Insert an empty line for new paragraphs.
- Insert an empty line between different markups (for example, after every
  paragraph, header, list, and so on). Example:

  ```markdown
  ## Header

  Paragraph.

  - List item 1
  - List item 2
  ```

### Emphasis

- Use double asterisks (`**`) to mark a word or text in bold (`**bold**`).
- Use underscore (`_`) for text in italics (`_italic_`).
- Use greater than (`>`) for blockquotes.

### Punctuation

Follow these guidelines for punctuation:

<!-- vale gitlab.Repetition = NO -->

| Rule                                                             | Example                                                |
|------------------------------------------------------------------|--------------------------------------------------------|
| Always end full sentences with a period.                         | _For a complete overview, read through this document._ |
| Always add a space after a period when beginning a new sentence. | _For a complete overview, check this doc. For other references, check out this guide._ |
| Do not use double spaces. (Tested in [`SentenceSpacing.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/SentenceSpacing.yml).) | --- |
| Do not use tabs for indentation. Use spaces instead. You can configure your code editor to output spaces instead of tabs when pressing the tab key. | --- |
| Use serial commas (_Oxford commas_) before the final _and_ or _or_ in a list of three or more items. (Tested in [`OxfordComma.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/OxfordComma.yml).) | _You can create new issues, merge requests, and milestones._ |
| Always add a space before and after dashes when using it in a sentence (for replacing a comma, for example). | _You should try this - or not._ |
| Always use lowercase after a colon.                              | _Related Issues: a way to create a relationship between issues._ |

<!-- vale gitlab.Repetition = YES -->

### Placeholder text

Often in examples, a writer will provide a command or configuration that
uses values specific to the reader.

In these cases, use [`<` and `>`](https://en.wikipedia.org/wiki/Usage_message#Pattern)
to call out where a reader must replace text with their own value.

For example:

```shell
cp <your_source_directory> <your_destination_directory>
```

### Keyboard commands

Use the HTML `<kbd>` tag when referring to keystroke presses. For example:

```plaintext
To stop the command, press <kbd>Ctrl</kbd>+<kbd>C</kbd>.
```

When the docs are generated, the output is:

To stop the command, press <kbd>Ctrl</kbd>+<kbd>C</kbd>.

## Lists

- Always start list items with a capital letter, unless they're parameters or
  commands that are in backticks, or similar.
- Always leave a blank line before and after a list.
- Begin a line with spaces (not tabs) to denote a [nested sub-item](#nesting-inside-a-list-item).

### Ordered vs. unordered lists

Only use ordered lists when their items describe a sequence of steps to follow.

Do:

```markdown
These are the steps to do something:

1. First, do the first step.
1. Then, do the next step.
1. Finally, do the last step.
```

Don't:

```markdown
This is a list of available features:

1. Feature 1
1. Feature 2
1. Feature 3
```

### Markup

- Use dashes (`-`) for unordered lists instead of asterisks (`*`).
- Prefix `1.` to every item in an ordered list. When rendered, the list items
  will appear with sequential numbering.

### Punctuation

- Don't add commas (`,`) or semicolons (`;`) to the ends of list items.
- Only add periods to the end of a list item if the item consists of a complete
  sentence (with a subject and a verb).
- Be consistent throughout the list: if the majority of the items do not end in
  a period, do not end any of the items in a period, even if they consist of a
  complete sentence. The opposite is also valid: if the majority of the items
  end with a period, end all with a period.
- Separate list items from explanatory text with a colon (`:`). For example:

  ```markdown
  The list is as follows:

  - First item: this explains the first item.
  - Second item: this explains the second item.
  ```

**Examples:**

Do:

- First list item
- Second list item
- Third list item

Don't:

- First list item
- Second list item
- Third list item.

Do:

- Let's say this is a complete sentence.
- Let's say this is also a complete sentence.
- Not a complete sentence.

Don't (vary use of periods; majority rules):

- Let's say this is a complete sentence.
- Let's say this is also a complete sentence.
- Not a complete sentence

### Nesting inside a list item

It's possible to nest items under a list item, so that they render with the same
indentation as the list item. This can be done with:

- [Code blocks](#code-blocks)
- [Blockquotes](#blockquotes)
- [Alert boxes](#alert-boxes)
- [Images](#images)

Items nested in lists should always align with the first character of the list
item. In unordered lists (using `-`), this means two spaces for each level of
indentation:

````markdown
- Unordered list item 1

  A line nested using 2 spaces to align with the `U` above.

- Unordered list item 2

  > A quote block that will nest
  > inside list item 2.

- Unordered list item 3

  ```plaintext
  a codeblock that will next inside list item 3
  ```

- Unordered list item 4

  ![an image that will nest inside list item 4](image.png)
````

For ordered lists, use three spaces for each level of indentation:

````markdown
1. Ordered list item 1

   A line nested using 3 spaces to align with the `O` above.

1. Ordered list item 2

   > A quote block that will nest
   > inside list item 2.

1. Ordered list item 3

   ```plaintext
   a codeblock that will next inside list item 3
   ```

1. Ordered list item 4

   ![an image that will nest inside list item 4](image.png)
````

You can nest full lists inside other lists using the same rules as above. If you
want to mix types, that's also possible, if you don't mix items at the same
level:

```markdown
1. Ordered list item one.
1. Ordered list item two.
   - Nested unordered list item one.
   - Nested unordered list item two.
1. Ordered list item three.

- Unordered list item one.
- Unordered list item two.
  1. Nested ordered list item one.
  1. Nested ordered list item two.
- Unordered list item three.
```

## Tables

Tables should be used to describe complex information in a straightforward
manner. Note that in many cases, an unordered list is sufficient to describe a
list of items with a single, simple description per item. But, if you have data
that's best described by a matrix, tables are the best choice.

### Creation guidelines

Due to accessibility and scannability requirements, tables should not have any
empty cells. If there is no otherwise meaningful value for a cell, consider entering
*N/A* (for 'not applicable') or *none*.

To help tables be easier to maintain, consider adding additional spaces to the
column widths to make them consistent. For example:

```markdown
| App name | Description          | Requirements   |
|:---------|:---------------------|:---------------|
| App 1    | Description text 1.  | Requirements 1 |
| App 2    | Description text 2.  | None           |
```

Consider installing a plugin or extension in your editor for formatting tables:

- [Markdown Table Prettifier](https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify) for Visual Studio Code
- [Markdown Table Formatter](https://packagecontrol.io/packages/Markdown%20Table%20Formatter) for Sublime Text
- [Markdown Table Formatter](https://atom.io/packages/markdown-table-formatter) for Atom

### Feature tables

When creating tables of lists of features (such as whether or not features are
available to certain roles on the [Permissions](../../user/permissions.md#project-members-permissions)
page), use the following phrases (based on the SVG icons):

| Option | Markdown                 | Displayed result       |
|--------|--------------------------|------------------------|
| No     | `**{dotted-circle}** No` | **{dotted-circle}** No |
| Yes    | `**{check-circle}** Yes` | **{check-circle}** Yes |

## Quotes

Valid for Markdown content only, not for front matter entries:

- Standard quotes: double quotes (`"`). Example: "This is wrapped in double
  quotes".
- Quote within a quote: double quotes (`"`) wrap single quotes (`'`). Example:
  "I am 'quoting' something within a quote".

For other punctuation rules, refer to the
[GitLab UX guide](https://design.gitlab.com/content/punctuation/).

## Headings

- Add _only one H1_ in each document, by adding `#` at the beginning of
  it (when using Markdown). The `h1` will be the document `<title>`.
- Start with an `h2` (`##`), and respect the order `h2` > `h3` > `h4` > `h5` > `h6`.
  Never skip the hierarchy level, such as `h2` > `h4`
- Avoid putting numbers in headings. Numbers shift, hence documentation anchor
  links shift too, which eventually leads to dead links. If you think it is
  compelling to add numbers in headings, make sure to at least discuss it with
  someone in the Merge Request.
- [Avoid using symbols and special characters](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/84)
  in headers. Whenever possible, they should be plain and short text.
- When possible, avoid including words that might change in the future. Changing
  a heading changes its anchor URL, which affects other linked pages.
- When introducing a new document, be careful for the headings to be
  grammatically and syntactically correct. Mention an [assigned technical writer (TW)](https://about.gitlab.com/handbook/product/product-categories/)
  for review.
  This is to ensure that no document with wrong heading is going live without an
  audit, thus preventing dead links and redirection issues when corrected.
- Leave exactly one blank line before and after a heading.
- Do not use links in headings.
- Add the corresponding [product badge](#product-badges) according to the tier the
  feature belongs.
- Our documentation site search engine prioritizes words used in headings and
  subheadings. Make you subheading titles clear, descriptive, and complete to help
  users find the right example, as shown in the section on [heading titles](#heading-titles).
- See [Capitalization](#capitalization) for guidelines on capitalizing headings.

### Heading titles

Keep heading titles clear and direct. Make every word count. To accommodate
search engine optimization (SEO), use the imperative, where possible.

| Do                                    | Don't                                                       |
|:--------------------------------------|:------------------------------------------------------------|
| Configure GDK                         | Configuring GDK                                             |
| GitLab Release and Maintenance Policy | This section covers GitLab's Release and Maintenance Policy |
| Backport to older releases            | Backporting to older releases                               |
| GitLab Pages examples                 | Examples                                                    |

For guidelines on capitalizing headings, see the section on [capitalization](#capitalization).

NOTE: **Note:**
If you change an existing title, be careful. These changes might affect not
only [links](#anchor-links) within the page, but might also affect links to the
GitLab documentation from both the GitLab application and external sites.

### Anchor links

Headings generate anchor links when rendered. `## This is an example` generates
the anchor `#this-is-an-example`.

NOTE: **Note:**
[Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/39717) in
GitLab 13.4, [product badges](#product-badges) used in headings aren't included
in the generated anchor links. For example, when you link to
`## This is an example **(CORE)**`, use the anchor `#this-is-an-example`.

Keep in mind that the GitLab user interface links to many documentation pages
and anchor links to take the user to the right spot. Therefore, when you change
a heading, search `doc/*`, `app/views/*`, and `ee/app/views/*` for the old
anchor to make sure you're not breaking an anchor linked from other
documentation nor from the GitLab user interface. If you find the old anchor, be
sure to replace it with the new one.

Important:

- Avoid crosslinking documentation to headings unless you need to link to a
  specific section of the document. This will avoid breaking anchors in the
  future in case the heading is changed.
- If possible, avoid changing headings since they're not only linked internally.
  There are various links to GitLab documentation on the internet, such as
  tutorials, presentations, StackOverflow posts, and other sources.
- Do not link to `h1` headings.

Note that, with Kramdown, it is possible to add a custom ID to an HTML element
with Markdown markup, but they _do not_ work in GitLab's `/help`. Therefore,
do not use this option until further notice.

## Links

Links are important in GitLab documentation. They allow you to [link instead of
summarizing](#link-instead-of-summarize) to help preserve a [single source of truth](#why-a-single-source-of-truth)
within GitLab documentation.

We include guidance for links in the following categories:

- How to set up [anchor links](#anchor-links) for headings.
- How to set up [criteria](#basic-link-criteria) for configuring a link.
- What to set up when [linking to a `help`](../documentation/index.md#linking-to-help)
  page.
- How to set up [links to internal documentation](#links-to-internal-documentation)
  for cross-references.
- How to set up [links to external documentation](#links-to-external-documentation)
  for authoritative sources.
- When to use [links requiring permissions](#links-requiring-permissions).
- How to set up a [link to a video](#link-to-video).
- How to [include links with version text](#text-for-documentation-requiring-version-text).
- How to [link to specific lines of code](#link-to-specific-lines-of-code)

### Basic link criteria

- Use inline link Markdown markup `[Text](https://example.com)`.
  It's easier to read, review, and maintain. _Do not_ use `[Text][identifier]`.

- Use [meaningful anchor texts](https://www.futurehosting.com/blog/links-should-have-meaningful-anchor-text-heres-why/).
  For example, instead of writing something like `Read more about GitLab Issue Boards [here](LINK)`,
  write `Read more about [GitLab Issue Boards](LINK)`.

### Links to internal documentation

NOTE: **Note:**
_Internal_ refers to documentation in the same project. When linking to
documentation in separate projects (for example, linking to Omnibus documentation
from GitLab documentation), you must use absolute URLs.

Do not use absolute URLs like `https://docs.gitlab.com/ee/index.html` to
crosslink to other documentation within the same project. Use relative links to
the file, like `../index.md`. (These are converted to HTML when the site is
rendered.)

Relative linking enables crosslinks to work:

- in Review Apps, local previews, and `/help`.
- when working on the documentation locally, so you can verify that they work as
  early as possible in the process.
- within the GitLab user interface when browsing doc files in their respective
  repositories. For example, the links displayed at
  `https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/README.md`.

To link to internal documentation:

- Use relative links to Markdown files in the same repository.
- Do not use absolute URLs or URLs from `docs.gitlab.com`.
- Use `../` to navigate to higher-level directories.
- Don't prepend `./` to links to files or directories.
- Don't link relative to root. For example, `/ee/user/gitlab_com/index.md`.

  Don't:

  - `https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html`
  - `/ee/administration/geo/replication/troubleshooting.md`
  - `./troubleshooting.md`

  Do: `../../geo/replication/troubleshooting.md`

- Always add the file name `file.md` at the end of the link with the `.md`
  extension, not `.html`.

  Don't:

  - `../../merge_requests/`
  - `../../issues/tags.html`
  - `../../issues/tags.html#stages`

  Do:

  - `../../merge_requests/index.md`
  - `../../issues/tags.md`
  - `../../issues/tags.md#stages`

NOTE: **Note:**
Using the Markdown extension is necessary for the [`/help`](index.md#gitlab-help)
section of GitLab.

### Links to external documentation

When describing interactions with external software, it's often helpful to
include links to external documentation. When possible, make sure that you're
linking to an [**authoritative** source](#authoritative-sources). For example,
if you're describing a feature in Microsoft's Active Directory, include a link
to official Microsoft documentation.

### Authoritative sources

When citing external information, use sources that are written by the people who
created the item or product in question. These sources are the most likely to be
accurate and remain up to date.

Examples of authoritative sources include:

- Specifications, such as a [Request for Comments](https://www.ietf.org/standards/rfcs/)
  document from the Internet Engineering Task Force.
- Official documentation for a product. For example, if you're setting up an
  interface with the Google OAuth 2 authorization server, include a link to
  Google's documentation.
- Official documentation for a project. For example, if you're citing NodeJS
  functionality, refer directly to [NodeJS documentation](https://nodejs.org/en/docs/).
- Books from an authoritative publisher.

Examples of sources to avoid include:

- Personal blog posts.
- Wikipedia.
- Non-trustworthy articles.
- Discussions on forums such as Stack Overflow.
- Documentation from a company that describes another company's product.

While many of these sources to avoid can help you learn skills and or features,
they can become obsolete quickly. Nobody is obliged to maintain any of these
sites. Therefore, we should avoid using them as reference literature.

NOTE: **Note:**
Non-authoritative sources are acceptable only if there is no equivalent
authoritative source. Even then, focus on non-authoritative sources that are
extensively cited or peer-reviewed.

### Links requiring permissions

Don't link directly to:

- [Confidential issues](../../user/project/issues/confidential_issues.md).
- Project features that require [special permissions](../../user/permissions.md)
  to view.

These will fail for:

- Those without sufficient permissions.
- Automated link checkers.

Instead:

- To reduce confusion, mention in the text that the information is either:
  - Contained in a confidential issue.
  - Requires special permission to a project to view.
- Provide a link in back ticks (`` ` ``) so that those with access to the issue
  can navigate to it.

Example:

```markdown
For more information, see the [confidential issue](../../user/project/issues/confidential_issues.md) `https://gitlab.com/gitlab-org/gitlab-foss/-/issues/<issue_number>`.
```

### Link to specific lines of code

When linking to specific lines within a file, link to a commit instead of to the
branch. Lines of code change through time, therefore, linking to a line by using
the commit link ensures the user lands on the line you're referring to. The
**Permalink** button, which is available when viewing a file within a project,
makes it easy to generate a link to the most recent commit of the given file.

- _Do_: `[link to line 3](https://gitlab.com/gitlab-org/gitlab/-/blob/11f17c56d8b7f0b752562d78a4298a3a95b5ce66/.gitlab/issue_templates/Feature%20proposal.md#L3)`
- _Don't_: `[link to line 3](https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/issue_templates/Feature%20proposal.md#L3).`

If that linked expression is no longer in that line of the file due to additional
commits, you can still search the file for that query. In this case, update the
document to ensure it links to the most recent version of the file.

## Images

Images, including screenshots, can help a reader better understand a concept.
However, they can be hard to maintain, and should be used sparingly.

Before including an image in the documentation, ensure it provides value to the
reader.

### Capture the image

Use images to help the reader understand where they are in a process, or how
they need to interact with the application.

When you take screenshots:

- _Capture the most relevant area of the page._ Don't include unnecessary white
  space or areas of the page that don't help illustrate the point. The left
  sidebar of the GitLab user interface can change, so don't include the sidebar
  if it's not necessary.
- _Keep it small._ If you don't need to show the full width of the screen, don't.
  A value of 1000 pixels is a good maximum width for your screenshot image.
- _Be consistent._ Coordinate screenshots with the other screenshots already on
  a documentation page. For example, if other screenshots include the left
  sidebar, include the sidebar in all screenshots.

### Save the image

- Save the image with a lowercase file name that's descriptive of the feature
  or concept in the image. If the image is of the GitLab interface, append the
  GitLab version to the file name, based on the following format:
  `image_name_vX_Y.png`. For example, for a screenshot taken from the pipelines
  page of GitLab 11.1, a valid name is `pipelines_v11_1.png`. If you're adding an
  illustration that doesn't include parts of the user interface, add the release
  number corresponding to the release the image was added to; for an MR added to
  11.1's milestone, a valid name for an illustration is `devops_diagram_v11_1.png`.
- Place images in a separate directory named `img/` in the same directory where
  the `.md` document that you're working on is located.
- Consider using PNG images instead of JPEG.
- [Compress all PNG images](#compress-images).
- Compress gifs with <https://ezgif.com/optimize> or similar tool.
- Images should be used (only when necessary) to _illustrate_ the description
  of a process, not to _replace_ it.
- Max image size: 100KB (gifs included).
- See also how to link and embed [videos](#videos) to illustrate the
  documentation.

### Add the image link to content

The Markdown code for including an image in a document is:
`![Image description which will be the alt tag](img/document_image_title_vX_Y.png)`

The image description is the alt text for the rendered image on the
documentation site. For accessibility and SEO, use [descriptions](https://webaim.org/techniques/alttext/)
that:

- Are accurate, succinct, and unique.
- Don't use _image of…_ or _graphic of…_ to describe the image.

### Compress images

You should always compress any new images you add to the documentation. One
known tool is [`pngquant`](https://pngquant.org/), which is cross-platform and
open source. Install it by visiting the official website and following the
instructions for your OS.

GitLab has a [Rake task](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/tasks/pngquant.rake)
that you can use to automate the process. In the root directory of your local
copy of `https://gitlab.com/gitlab-org/gitlab`, run in a terminal:

- Before compressing, if you want, check that all documentation PNG images have
  been compressed:

  ```shell
  bundle exec rake pngquant:lint
  ```

- Compress all documentation PNG images using `pngquant`:

  ```shell
  bundle exec rake pngquant:compress
  ```

The only caveat is that the task runs on all images under `doc/`, not only the
ones you might have included in a merge request. In that case, you can run the
compress task and only commit the images that are relevant to your merge
request.

## Videos

Adding GitLab's existing YouTube video tutorials to the documentation is highly
encouraged, unless the video is outdated. Videos should not replace
documentation, but complement or illustrate it. If content in a video is
fundamental to a feature and its key use cases, but this is not adequately
covered in the documentation, add this detail to the documentation text or
create an issue to review the video and do so.

Do not upload videos to the product repositories. [Link](#link-to-video) or
[embed](#embed-videos) them instead.

### Link to video

To link out to a video, include a YouTube icon so that readers can scan the page
for videos before reading:

```markdown
<i class="fa fa-youtube-play youtube" aria-hidden="true"></i>
For an overview, see [Video Title](link-to-video).
```

You can link any up-to-date video that's useful to the GitLab user.

### Embed videos

> [Introduced](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/472) in GitLab 12.1.

The [GitLab documentation site](https://docs.gitlab.com) supports embedded
videos.

You can only embed videos from [GitLab's official YouTube account](https://www.youtube.com/channel/UCnMGQ8QHMAnVIsI3xJrihhg).
For videos from other sources, [link](#link-to-video) them instead.

In most cases, it is better to [link to video](#link-to-video) instead, because
an embed takes up a lot of space on the page and can be distracting to readers.

To embed a video:

1. Copy the code from this procedure and paste it into your Markdown file. Leave a
   blank line above and below it. Do _not_ edit the code (don't remove or add any spaces).
1. In YouTube, visit the video URL you want to display. Copy the regular URL
   from your browser (`https://www.youtube.com/watch?v=VIDEO-ID`) and replace
   the video title and link in the line under `<div class="video-fallback">`.
1. In YouTube, select **Share**, and then select **Embed**.
1. Copy the `<iframe>` source (`src`) **URL only**
   (`https://www.youtube.com/embed/VIDEO-ID`),
   and paste it, replacing the content of the `src` field in the
   `iframe` tag.

```html
leave a blank line here
<div class="video-fallback">
  See the video: <a href="https://www.youtube.com/watch?v=MqL6BMOySIQ">Video title</a>.
</div>
<figure class="video-container">
  <iframe src="https://www.youtube.com/embed/MqL6BMOySIQ" frameborder="0" allowfullscreen="true"> </iframe>
</figure>
leave a blank line here
```

This is how it renders on the GitLab documentation site:

<div class="video-fallback">
  See the video: <a href="https://www.youtube.com/watch?v=enMumwvLAug">What is GitLab</a>.
</div>
<figure class="video-container">
  <iframe src="https://www.youtube.com/embed/MqL6BMOySIQ" frameborder="0" allowfullscreen="true"> </iframe>
</figure>

> Notes:
>
> - The `figure` tag is required for semantic SEO and the `video_container`
class is necessary to make sure the video is responsive and displays on
different mobile devices.
> - The `<div class="video-fallback">` is a fallback necessary for GitLab's
`/help`, as GitLab's Markdown processor does not support iframes. It's hidden on
the documentation site, but will be displayed on GitLab's `/help`.
