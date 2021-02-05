---
type: reference, dev
stage: none
group: Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

This page is about developing dark mode for GitLab. For how to enable dark mode, see the [dark mode user docs](https://docs.gitlab.com/ee/user/profile/preferences.html#dark-mode).

# How dark mode works

TLDR: We reverse the color palette and override a few bootstrap variables.

Note the following:

- The dark mode palette is defined in `app/assets/stylesheets/themes/_dark.scss`.
  This is loaded _before_ application.scss to generate `application_dark.css`
  - We define two types of variables in `_dark.scss`:
    - SCSS variables are used in framework, components, and utitlity classes.
    - CSS variables are used for any colors within the `app/assets/stylesheets/page_bundles` directory.
- `app/views/layouts/_head.html.haml` then loads application or application_dark based on the user's theme preference.

Because we didn't want to generate separate `_dark.css` variants of every page_bundle file,
we use CSS variables with SCSS variables as fallbacks. This is because when we generate the `page_bundles`
CSS, we get the variable values from `_variables.scss`, so any SCSS variables have light mode values.

The CSS variables defined in `_dark.scss` are available in the browser though, so those will have the correct colors.

```scss
color: var(--gray-500, $gray-500);
```

## Utility classes

We generate a separate `utilities_dark.css` file for utility classes containing the inverted values. So a class
such as `gl-text-white` will give text color of `#333` in dark mode. This is done intentionally so you are not
required to add multiple classes every time you want to add a color.

There is currently not a way to use a utility class only in dark mode, there is [an issue](https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1141)
to add support for this.

## Using different values in light and dark mode

Ideally we use the same values for both light and dark mode, for most things this works. There are some cases where we need a different value for dark mode.

You can add am override using the `.gl-dark` class that dark mode adds to `body`

```scss
color: $gray-700;
.gl-dark & {
  color: var(--gray-500);
}
```

NOTE:
Avoid using a different value for the SCSS fallback

```scss
// avoid where possible
// --gray-500 (#999) in dark mode
// $gray-700 (#525252) in light mode
color: var(--gray-500, $gray-700);
```

We [plan to add](https://gitlab.com/gitlab-org/gitlab/-/issues/301147) the CSS variables to light mode. When that happens, different values for the SCSS fallback will no longer work.

## Why don't we use CSS variables everywhere

We probably will. But there are still a few things we do in SCSS that we cannot (easily) do with CSS. Some examples are the `lighten`, `darken` and `color-yiq` (color contrast) functions. There are also some tricky gotchas. For example, the following will not work:

```scss
color: rgba(var(--black), 0.5);
```

It will compile, and in devtools it will appear as a valid style. But because our CSS variables are defined as hex (ie. `--black: #222`), then that style computes to `rgba(#222, 0.5)`, which is _not_ valid CSS!
