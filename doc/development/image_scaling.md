---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Image scaling guide

This section contains a brief overview of GitLab's image scaler and how to work with it.

## Why image scaling?

Since version 13.6, GitLab scales down images on demand in order to reduce the page data footprint.
This both reduces the amount of data "on the wire", but also helps with rendering performance,
since the browser has less work to do.

## When do we scale images?

Generally, the image scaler is triggered whenever a client requests an image resource by adding
the `width` parameter to the query string. However, we only scale images of certain kinds and formats.
Whether we allow an image to be rescaled or not is decided on a combination of hard-coded rules and configuration settings.

The hard-coded rules only permit:

- [Project, group and user avatars](https://gitlab.com/gitlab-org/gitlab/-/blob/fd08748862a5fe5c25b919079858146ea85843ae/app/controllers/concerns/send_file_upload.rb#L65-67)
- [PNGs or JPEGs](https://gitlab.com/gitlab-org/gitlab/-/blob/5dff8fa3814f2a683d8884f468cba1ec06a60972/lib/gitlab/file_type_detection.rb#L23)
- [Specific dimensions](https://gitlab.com/gitlab-org/gitlab/-/blob/5dff8fa3814f2a683d8884f468cba1ec06a60972/app/models/concerns/avatarable.rb#L6)

Furthermore, configuration in Workhorse can lead to the image scaler rejecting a request if:

- The image file is too large (controlled by [`max_filesize`](- we only rescale images that do not exceed a configured size in bytes (see [`max_filesize`](https://gitlab.com/gitlab-org/gitlab-workhorse/-/blob/67ab3a2985d2097392f93523ae1cffe0dbf01b31/config.toml.example#L17))))
- Too many image scalers are already running (controlled by [`max_scaler_procs`](https://gitlab.com/gitlab-org/gitlab-workhorse/-/blob/67ab3a2985d2097392f93523ae1cffe0dbf01b31/config.toml.example#L16))

For instance, here are two different URLs that serve the GitLab project avatar in its
original size, and scaled down to 64 pixels. Only the second request will trigger the image scaler:

- https://assets.gitlab-static.net/uploads/-/system/project/avatar/278964/logo-extra-whitespace.png
- https://assets.gitlab-static.net/uploads/-/system/project/avatar/278964/logo-extra-whitespace.png?width=64

