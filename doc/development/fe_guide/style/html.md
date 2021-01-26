---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# HTML style guide

See also our [accessibility page](../accessibility.md).

## Buttons

### Button type

Button tags requires a `type` attribute according to the [W3C HTML specification](https://www.w3.org/TR/2011/WD-html5-20110525/the-button-element.html#dom-button-type).

```html
// bad
<button></button>

// good
<button type="button"></button>
```

## Links

### Blank target

Use `rel="noopener noreferrer"` whenever your links open in a new window, i.e. `target="_blank"`. This prevents a security vulnerability [documented by JitBit](https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/).

When using `gl-link`, using `target="_blank"` is sufficient as it automatically adds `rel="noopener noreferrer"` to the link.

```html
// bad
<a href="url" target="_blank"></a>

// good
<a href="url" target="_blank" rel="noopener noreferrer"></a>

// good
<gl-link href="url" target="_blank"></gl-link>
```

### Fake links

**Do not use fake links.** Use a button tag if a link only invokes JavaScript click event handlers, which is more semantic.

```html
// bad
<a class="js-do-something" href="#"></a>

// good
<button class="js-do-something" type="button"></button>
```
