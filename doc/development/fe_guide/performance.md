---
stage: none
group: unassigned
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Performance

## Measure, monitor and optimize performance with User Timing API

[User Timing API](https://developer.mozilla.org/en-US/docs/Web/API/User_Timing_API) is a web API [available in all modern browsers](https://caniuse.com/?search=User%20timing) that allows measuring custom times and durations in your applications  automatically by placing special marks in your code.

User Timing API introduces two important paradigms: `mark` and `measure`.

**Mark** — is the simple timestamp on the performance timeline. For example, `performance.mark('my-component-start');` will make a browser automatically note the time this code is met. Afterwards, the information about this mark can be obtained by querying the global performance object again. For example in your DevTool’s console:

```javascript
performance.getEntriesByName('my-component-start')
```

**Measure** — is the duration between either two marks, or start of navigation and a mark, or start of navigation and the moment the measurement is taken. It takes at least one required argument that is the measurement’s name. Examples:

1. Duration between the start and end marks:
```javascript
performance.measure('My component', 'my-component-start', 'my-component-end')
```
1. Duration between a mark and the moment the measurement is taken. The end mark can be omitted in this case.
```javascript
performance.measure('My component', 'my-component-start')
```
1. Duration between navigation start and the moment the measurement is taken. Both, the start and the end marks can be omitted in this case.
```javascript
performance.measure('My component')
```
1. Duration between navigation start and a mark. The start mark can not be omitted in this case but can be set to `undefined``.
```javascript
performance.measure('My component', undefined, 'my-component-end')
```
However, keep in mind that it is the same as checking the  `my-component-end` mark directly.

One can also query for all marks or metrics gathered by the browser:

```javascript
performance.getEntriesByType('mark');
performance.getEntriesByType('measure');
```

User Timing API at GitLab can be used for measuring any timings in the framework-agnostic manner no matter Rails, Vue or vanilla  JavaScript environment. For consistency and the convenience of its adoption, GitLab offers several ways of enabling custom user timing metrics in your code.

### `performanceMarkAndMeasure` Utility

This utility can be used anywhere in the product as it is not tied to any particular environment. Example:

```javascript
import { performanceMarkAndMeasure } from '~/performance/utils';
...
performanceMarkAndMeasure({
  mark: MR_DIFFS_MARK_DIFF_FILES_END,
  measures: [
    {
      name: MR_DIFFS_MEASURE_DIFF_FILES_DONE,
      start: MR_DIFFS_MARK_DIFF_FILES_START,
      end: MR_DIFFS_MARK_DIFF_FILES_END,
    },
  ],
});
```

`performanceMarkAndMeasure` takes an object as an argument, where:

* `mark`: `String` representing the name for the mark to set. Used for retrieving the mark later
* `measures`: an `Array` of the measurements to take at this point. Every measurement entry can have:
  *  `name`: `String` Represents the measurement's name.  Used for retrieving the measurement later.
  *  `start`: `String` the name of a mark **from** which the measurement should be taken
  *  `end`: `String` the name of a mark **to** which the measurement should be taken
  
All of the properties above are optional except for `name` in a measurement: JS will fail if you try to measure performance without specifying the name.

### Vue Performance Plugin

The plugin captures and measures performance of the specified Vue components automatically using User Timing API.

### How to use it?

1. Import the plugin:

```javascript
import PerformancePlugin from '~/performance/vue_performance_plugin';
```

2. Then… use it before initializing your Vue application :sweat_smile: 

```javascript
/* eslint-disable @gitlab/require-i18n-strings */
Vue.use(PerformancePlugin, {
  components: [
    'IdeTreeList',
    'FileTree',
    'RepoEditor',
  ]
});
/* eslint-enable @gitlab/require-i18n-strings */
```

The plugin accepts the list of `components` performance of which should be measured. The components should be specified by their `name` option.

:warning: This might require the authors to explicitly set this option on the needed components as most components in the codebase don't have this option set at the moment:

```javascript
export default {
  name: 'IdeTreeList',
  components: {
    ...
  ...
}
```

The plugin will capture and store:

  * start **mark** for when the component has been initialized (in `beforeCreate()` hook)
  * end **mark** of the component when it has been rendered (next animation frame after `nextTick` in `mounted()` hook)
  * **measure** duration between the two marks above.

### How to access the stored measurements?

1. **Performance Bar**. If you have it enabled (`P` + `B` keycombo), you will see the metrics output in your DevTools' console.
1. **"Performance" tab** of the DevTools. You can get the measurements (not the marks, though) in this tab when profiling performance
1. **DevTools' Console**. As mentioned above, one can simply query for the entries:

```javascript
performance.getEntriesByType('mark');
performance.getEntriesByType('measure');
```

## Naming Convention

All the marks and measures should be instantiated with the constants from `app/assets/javascripts/performance/constants.js`. Once you’re ready to add a new mark’s or measurement’s label, it is advised to follow the scheme:

```
APP-*-start // for a start ‘mark’
APP-*-end   // for an end ‘mark’
APP-*       // for ‘measure’
```

For example, `webide-nav-tree-start`, `snippet-blob-end`, etc. This is done to be able to easily identify marks and measures coming from the different apps on the same page. Note, however, that this schema is a recommendation and not a hard rule.


## Best Practices

### Realtime Components

When writing code for realtime features we have to keep a couple of things in mind:

1. Do not overload the server with requests.
1. It should feel realtime.

Thus, we must strike a balance between sending requests and the feeling of realtime.
Use the following rules when creating realtime solutions.

1. The server will tell you how much to poll by sending `Poll-Interval` in the header.
   Use that as your polling interval. This way it is [easy for system administrators to change the
   polling rate](../../administration/polling.md).
   A `Poll-Interval: -1` means you should disable polling, and this must be implemented.
1. A response with HTTP status different from 2XX should disable polling as well.
1. Use a common library for polling.
1. Poll on active tabs only. Please use [Visibility](https://github.com/ai/visibilityjs).
1. Use regular polling intervals, do not use backoff polling, or jitter, as the interval will be
   controlled by the server.
1. The backend code will most likely be using etags. You do not and should not check for status
   `304 Not Modified`. The browser will transform it for you.

### Lazy Loading Images

To improve the time to first render we are using lazy loading for images. This works by setting
the actual image source on the `data-src` attribute. After the HTML is rendered and JavaScript is loaded,
the value of `data-src` will be moved to `src` automatically if the image is in the current viewport.

- Prepare images in HTML for lazy loading by renaming the `src` attribute to `data-src` AND adding the class `lazy`.
- If you are using the Rails `image_tag` helper, all images will be lazy-loaded by default unless `lazy: false` is provided.

If you are asynchronously adding content which contains lazy images then you need to call the function
`gl.lazyLoader.searchLazyImages()` which will search for lazy images and load them if needed.
But in general it should be handled automatically through a `MutationObserver` in the lazy loading function.

### Animations

Only animate `opacity` & `transform` properties. Other properties (such as `top`, `left`, `margin`, and `padding`) all cause
Layout to be recalculated, which is much more expensive. For details on this, see "Styles that Affect Layout" in
[High Performance Animations](https://www.html5rocks.com/en/tutorials/speed/high-performance-animations/).

If you _do_ need to change layout (e.g. a sidebar that pushes main content over), prefer [FLIP](https://aerotwist.com/blog/flip-your-animations/) to change expensive
properties once, and handle the actual animation with transforms.

## Reducing Asset Footprint

### Universal code

Code that is contained within `main.js` and `commons/index.js` are loaded and
run on _all_ pages. **DO NOT ADD** anything to these files unless it is truly
needed _everywhere_. These bundles include ubiquitous libraries like `vue`,
`axios`, and `jQuery`, as well as code for the main navigation and sidebar.
Where possible we should aim to remove modules from these bundles to reduce our
code footprint.

### Page-specific JavaScript

Webpack has been configured to automatically generate entry point bundles based
on the file structure within `app/assets/javascripts/pages/*`. The directories
within the `pages` directory correspond to Rails controllers and actions. These
auto-generated bundles will be automatically included on the corresponding
pages.

For example, if you were to visit <https://gitlab.com/gitlab-org/gitlab/-/issues>,
you would be accessing the `app/controllers/projects/issues_controller.rb`
controller with the `index` action. If a corresponding file exists at
`pages/projects/issues/index/index.js`, it will be compiled into a webpack
bundle and included on the page.

Previously, GitLab encouraged the use of
`content_for :page_specific_javascripts` within HAML files, along with
manually generated webpack bundles. However under this new system you should
not ever need to manually add an entry point to the `webpack.config.js` file.

TIP: **Tip:**
If you are unsure what controller and action corresponds to a given page, you
can find this out by inspecting `document.body.dataset.page` within your
browser's developer console while on any page within GitLab.

#### Important Considerations

- **Keep Entry Points Lite:**
  Page-specific JavaScript entry points should be as lite as possible. These
  files are exempt from unit tests, and should be used primarily for
  instantiation and dependency injection of classes and methods that live in
  modules outside of the entry point script. Just import, read the DOM,
  instantiate, and nothing else.

- **`DOMContentLoaded` should not be used:**
  All of GitLab's JavaScript files are added with the `defer` attribute.
  According to the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-defer),
  this implies that "the script is meant to be executed after the document has
  been parsed, but before firing `DOMContentLoaded`". Since the document is already
  parsed, `DOMContentLoaded` is not needed to bootstrap applications because all
  the DOM nodes are already at our disposal.

- **JavaScript that relies on CSS for calculations should use [`waitForCSSLoaded()`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/assets/javascripts/helpers/startup_css_helper.js#L34):**
  GitLab uses [Startup.css](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/38052)
  to improve page performance. This can cause issues if JavaScript relies on CSS
  for calculations. To fix this the JavaScript can be wrapped in the 
  [`waitForCSSLoaded()`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/assets/javascripts/helpers/startup_css_helper.js#L34)
  helper function.

  ```javascript
  import initMyWidget from './my_widget';
  import { waitForCSSLoaded } from '~/helpers/startup_css_helper';

  waitForCSSLoaded(initMyWidget);
  ```

  Note that `waitForCSSLoaded()` methods supports receiving the action in different ways:
    
  - With a callback:
  
    ```javascript
      waitForCSSLoaded(action)
    ```
    
  - With `then()`:
  
    ```javascript
      waitForCSSLoaded().then(action);
    ```
    
  - With `await` followed by `action`:
  
    ```javascript
      await waitForCSSLoaded;
      action();
    ```

  For example, see how we use this in [app/assets/javascripts/pages/projects/graphs/charts/index.js](https://gitlab.com/gitlab-org/gitlab/-/commit/5e90885d6afd4497002df55bf015b338efcfc3c5#02e81de37f5b1716a3ef3222fa7f7edf22c40969_9_8):

  ```javascript
  waitForCSSLoaded(() => {
    const languagesContainer = document.getElementById('js-languages-chart');
    //...
  });
  ```

- **Supporting Module Placement:**
  - If a class or a module is _specific to a particular route_, try to locate
    it close to the entry point it will be used. For instance, if
    `my_widget.js` is only imported within `pages/widget/show/index.js`, you
    should place the module at `pages/widget/show/my_widget.js` and import it
    with a relative path (e.g. `import initMyWidget from './my_widget';`).
  - If a class or module is _used by multiple routes_, place it within a
    shared directory at the closest common parent directory for the entry
    points that import it. For example, if `my_widget.js` is imported within
    both `pages/widget/show/index.js` and `pages/widget/run/index.js`, then
    place the module at `pages/widget/shared/my_widget.js` and import it with
    a relative path if possible (e.g. `../shared/my_widget`).

- **Enterprise Edition Caveats:**
  For GitLab Enterprise Edition, page-specific entry points will override their
  Community Edition counterparts with the same name, so if
  `ee/app/assets/javascripts/pages/foo/bar/index.js` exists, it will take
  precedence over `app/assets/javascripts/pages/foo/bar/index.js`. If you want
  to minimize duplicate code, you can import one entry point from the other.
  This is not done automatically to allow for flexibility in overriding
  functionality.

### Code Splitting

For any code that does not need to be run immediately upon page load, (e.g.
modals, dropdowns, and other behaviors that can be lazy-loaded), you can split
your module into asynchronous chunks with dynamic import statements. These
imports return a Promise which will be resolved once the script has loaded:

```javascript
import(/* webpackChunkName: 'emoji' */ '~/emoji')
  .then(/* do something */)
  .catch(/* report error */)
```

Please try to use `webpackChunkName` when generating these dynamic imports as
it will provide a deterministic filename for the chunk which can then be cached
the browser across GitLab versions.

More information is available in [webpack's code splitting documentation](https://webpack.js.org/guides/code-splitting/#dynamic-imports).

### Minimizing page size

A smaller page size means the page loads faster (especially important on mobile
and poor connections), the page is parsed more quickly by the browser, and less
data is used for users with capped data plans.

General tips:

- Don't add new fonts.
- Prefer font formats with better compression, e.g. WOFF2 is better than WOFF, which is better than TTF.
- Compress and minify assets wherever possible (For CSS/JS, Sprockets and webpack do this for us).
- If some functionality can reasonably be achieved without adding extra libraries, avoid them.
- Use page-specific JavaScript as described above to load libraries that are only needed on certain pages.
- Use code-splitting dynamic imports wherever possible to lazy-load code that is not needed initially.
- [High Performance Animations](https://www.html5rocks.com/en/tutorials/speed/high-performance-animations/)

---

## Additional Resources

- [WebPage Test](https://www.webpagetest.org) for testing site loading time and size.
- [Google PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/) grades web pages and provides feedback to improve the page.
- [Profiling with Chrome DevTools](https://developers.google.com/web/tools/chrome-devtools/)
- [Browser Diet](https://browserdiet.com/) is a community-built guide that catalogues practical tips for improving web page performance.
