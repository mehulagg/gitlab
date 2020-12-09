---
type: reference, dev
stage: none
group: Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# How dark mode works

TLDR: We reverse the color palette and override a few bootstrap variables.

When setting `color`, `background-color` or other color-related rules, use CSS variables 
(especially if in `page_bundles` bundles).

For all pages except for the WebIDE, dark mode works like this:

The dark mode palette is defined in `app/assets/stylesheets/themes/_dark.scss`.
This is loaded _before_ application.scss to generate `application_dark.css`
`app/views/layouts/_head.html.haml` then loads the correct application and utilities css based on the user's theme preference.

We define two types of variables in `_dark.scss`:
SCSS variables are used in framework, components, and utitlity classes
CSS variables are used for any colors within the `app/assets/stylesheets/page_bundles` directory.

Because we didn't want to generate separate `_dark.css` variants of every page_bundle file,
we use CSS variables with SCSS variables as fallbacks. This is because when we generate the `page_bundles`
CSS, we get the variable values from `_variables.scss`, so any SCSS variables have light mode values.

The CSS variables defined in `_dark.scss` are available in the browser though, so those will have the correct colors.

```scss
color: var(--gray-500, $gray-500);
```

## Using different values in light and dark mode

Ideally we use the same values for both light and dark mode, for most things this works. There are some cases where we need a different value for some reason. The current preferred approach is still being decided, use your judgement when choosing what to do.

Option 1: Add override using the `.dark-mode` class added to `body`

```scss
color: $gray-700;
.gl-dark & {
  color: var(--gray-500);
}
```

we could probably make this into a function or mixin:

```scss
color: $gray-700;
@include dark-mode-override(color, --gray-500);
```

If there are multiple usages of the overridden color, you can define a local
CSS variable, scoped to your component. Then you only need a single override and use your value throughtout.

```css
.my-component {
  --component-text-color: #333;

  .dark-mode & {
    --component-text-color: #eee;
  }

  color: var(--component-text-color);
}

/* depends on this header being a child of `my-component` */
.my-component-header {
  border-bottom: solid 2px var(--component-text-color);
}
```

Please avoid using a different value for the SCSS fallback:

```scss
// avoid where possible
// --gray-500 (#999) in dark mode
// $gray-700 (#525252) in light mode
color: var(--gray-500, $gray-700);
```

There are some existing instances of this, but as we plan to add the CSS variables to light mode as well this will no longer work.

## Why don't we use CSS variables everywhere

We probably will. But there are still a few things we do in SCSS that we cannot (easily) do with CSS. Some examples are the `lighten`, `darken` and `color-yiq` (color contrast) functions. There are also some tricky gotchas. For example, the following will not work:

```scss
color: rgba(var(--black), 0.5);
```

It will compile, and in devtools it will appear as a valid style. But because our CSS variables are defined as hex (ie. `--black: #222`), then that style computes to `rgba(#222, 0.5)`, which is _not_ valid CSS!
