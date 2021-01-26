---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Accessibility

Accessibility is important so that our users who rely on screen readers or who only use keyboards get an equivalent experience to sighted mouse users.

This page contains guidelines we should follow.

## Quick summary

Since [no ARIA is better than bad ARIA](https://www.w3.org/TR/wai-aria-practices/#no_aria_better_bad_aria),
avoid using `aria-*`, `role`, and `tabindex`.
Use semantic html, which has accessibility semantics baked in, and you should generally be okay.

In [WebAIM's accessibility analysis of the top million home pages](https://webaim.org/projects/million/#aria),
they found that "ARIA correlated to higher detectable errors".
It is likely that *misuse* of ARIA is a big cause of increased errors,
so when in doubt don't use `aria-*`, `role`, and `tabindex`, and stick with semantic html.

## Provide accessible names to screen readers

To provide markup with accessible names, ensure every:

- `input` has an associated `label`
- `button` and `a` have child text 
- `img` has an `alt` attribute
- `fieldset` has `legend` as its first child
- `figure` has `figcaption` as its first child
- `table` has `caption` as its first child

If the `label`, child text, or child element is not visually desired,
use `.gl-sr-only` to hide the element visually but keep it visible to screen readers.

## Roles

In general, avoid using `role`.
Use semantic html elements that implicitly have a `role` instead.

| Bad | Good |
| --- | --- |
| `<div role="button">` | `<button>` |
| `<div role="img">` | `<img>` |
| `<div role="link">` | `<a>` |
| `<div role="header">` | `<h1>` to `<h6>` |
| `<div role="textbox">` | `<input>` or `<textarea>` |
| `<div role="article">` | `<article>` |
| `<div role="list">` | `<ol>` or `<ul>` |
| `<div role="listitem">` | `<li>` |
| `<div role="table">` | `<table>` |
| `<div role="rowgroup">` | `<thead>`, `<tbody>`, or `<tfoot>` |
| `<div role="row">` | `<tr>` |
| `<div role="columnheader">` | `<th>` |
| `<div role="cell">` | `<td>` |

## Maintain tab accessibility

Keyboard users rely on focus outlines to understand where they are on the page. Therefore, if an
element is interactive you must ensure:

- It can be tabbed to
- It has a focus outline

Use semantic html, such as `a` and `button`, to get this for free.

## Tabindex

Prefer **no** `tabindex` to using `tabindex`, since:

- Using semantic html such as `button` implicitly provides `tabindex="0"`
- Tabbing order should match the visual reading order and positive `tabindex`s interfere with this

### Avoid using `tabindex="0"` to make an element interactive

If an element isn't interactive but should be, use an interactive element instead.
For example: 

- If the element should be clickable, use a `button`
- If the element should be text editable, use an `input` or `textarea`

Once the markup is semantically complete, use css to update it to its desired visual state.

```html
// bad
<div role="button" @click="expand">Expand</div>

// good
<button @click="expand">Expand</button>
```

### Do not use `tabindex="0"` on interactive elements

Interactive elements are already tab accessible so adding `tabindex` is redundant.

```html
// bad
<a href="help" tabindex="0">Help</a>
<button tabindex="0">Submit</button>

// good
<a href="help">Help</a>
<button>Submit</button>
```

### Do not use `tabindex="0"` on elements for screen readers to read

Screen readers can read text that is not tab accessible.
Therefore, adding `tabindex="0"` is unnecessary but is also worse as screen reader users then expect to be able to interact with it.

```html
// bad
<span tabindex="0" :aria-label="message">{{ message }}</span>

// good
<p>{{ message }}</p>
```

### Do not use a positive `tabindex`

`tabindex="1"` or greater [must always be avoided](https://webaim.org/techniques/keyboard/tabindex#overview).

## Hiding elements

Use the following table to hide elements from users appropriately.

| Hide from sighted users | Hide from screen readers | Hide from both sighted and screen reader users |
| --- | --- | --- |
| `.gl-sr-only` | `aria-hidden="true"` | `display: none`, `visibility: hidden`, or `hidden` attribute |

### Hide decorative images from screen readers

To reduce noise for screen reader users, hide decorative images using `aria-hidden="true"`.

`gl-icon` components automatically hide their icons from screen readers so `aria-hidden="true"` is
unnecessary when using `gl-icon`.

## When should ARIA be used

When using semantic html, no ARIA is required because it has accessibility semantics baked in.

However, there are some UI patterns and widgets that do not have semantic html equivalents.
Building such widgets require ARIA to make them understandable to screen readers.
Proper research and testing should be done to ensure compliance with ARIA.

Ideally, these widgets would exist only in [GitLab UI](https://gitlab-org.gitlab.io/gitlab-ui/).
Use of ARIA would then only occur in [GitLab UI](https://gitlab.com/gitlab-org/gitlab-ui/) and not [GitLab](https://gitlab.com/gitlab-org/gitlab/).

## Resources

### Viewing the browser accessibility tree

- [Firefox DevTools guide](https://developer.mozilla.org/en-US/docs/Tools/Accessibility_inspector#accessing_the_accessibility_inspector)
- [Chrome DevTools guide](https://developers.google.com/web/tools/chrome-devtools/accessibility/reference#pane)

### Browser extensions

- [axe](https://www.deque.com/axe/) for [Firefox](https://addons.mozilla.org/en-US/firefox/addon/axe-devtools/) 
- [axe](https://www.deque.com/axe/) for [Chrome](https://chrome.google.com/webstore/detail/axe-web-accessibility-tes/lhdoppojpmngadmnindnejefpokejbdd) 

### Other links

- [Awesome Accessibility](https://github.com/brunopulis/awesome-a11y)
  is a compilation of accessibility-related material
- You can read [Chrome Accessibility Developer Tools'](https://github.com/GoogleChrome/accessibility-developer-tools)
  rules on its [Audit Rules page](https://github.com/GoogleChrome/accessibility-developer-tools/wiki/Audit-Rules)
