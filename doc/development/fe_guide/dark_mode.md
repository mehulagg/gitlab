---
type: reference, dev
stage: none
group: Development
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# How Dark mode works

Short version: Reverse the color palette and override a few Bootstrap variables.

When setting `color`, `background-color` or other color-related rules, use CSS variables 
(especially if in `page_bundles` bundles).

For all pages except for the WebIDE, dark mode works like this:

The dark mode palette is defined in `app/assets/stylesheets/themes/_dark.scss`.
This is loaded _before_ application.scss to generate `application_dark.css`
`app/views/layouts/_head.html.haml` then loads the correct application and utilities css based on the user's theme preference.

We define two types of variables in `_dark.scss`:
SCSS variables are used in framework, components, and utitlity classes
CSS variables are used for any colors within the `app/assets/stylesheets/page_bundles` directory.

As we do not want to generate separate `_dark.css` variants of every page_bundle file,
we use CSS variables with SCSS variables as fallbacks. This is because when we generate the `page_bundles`
CSS, we get the variable values from `_variables.scss`, so any SCSS variables have light mode values.

As the CSS variables defined in `_dark.scss` are available in the browser, they have the
correct colors for dark mode.

```scss
color: var(--gray-500, $gray-500);
```

## Utility classes

We generate a separate `utilities_dark.css` file for utility classes containing the inverted values. So a class
such as `gl-text-white` specifies a text color of `#333` in dark mode. This means you do not have to
add multiple classes every time you want to add a color.

Currently, we cannot set up a utility class only in dark mode. We hope to address that
[issue](https://gitlab.com/gitlab-org/gitlab-ui/-/issues/1141) soon.

## Using different values in light and dark mode

In most cases, we can use the same values for light and dark mode. If that is not possible, you
have options:

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
// NB: this does not actually exist yet
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

## When to use SCSS variables

There are a few things we do in SCSS that we cannot (easily) do with CSS, such as the following
functions: 

- `lighten`
- `darken`
- `color-yiq` (color contrast)

Not all SCSS variables, even if they compile, are valid. For example, the following SCSS variable
does not work:

```scss
color: rgba(var(--black), 0.5);
```

It compiles. It even appears as a valid style in your browser's developer tools. However, since
our CSS variables are defined in hex format, such as `--black: #222`, that style
computes to `rgba(#222, 0.5)`, which is _not_ valid CSS!
