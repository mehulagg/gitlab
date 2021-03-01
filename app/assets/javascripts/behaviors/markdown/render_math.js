import $ from 'jquery';
import { deprecatedCreateFlash as flash } from '~/flash';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';
import { s__, __, sprintf } from '~/locale';

// Renders math using KaTeX in any element with the
// `js-render-math` class
//
// ### Example Markup
//
//   <code class="js-render-math"></div>
//

const MAX_MATH_CHARS = 1000;
const MAX_RENDER_TIME_MS = 2000;

// These messages might be used with inline errors in the future. Keep them around. For now, we will
// display a single error message using flash().

// const CHAR_LIMIT_EXCEEDED_MSG = sprintf(
//   s__(
//     'math|The following math is too long. For performance reasons, math blocks are limited to %{maxChars} characters. Try splitting up this block, or include an image instead.',
//   ),
//   { maxChars: MAX_MATH_CHARS },
// );
// const RENDER_TIME_EXCEEDED_MSG = s__(
//   "math|The math in this entry is taking too long to render. Any math below this point won't be shown. Consider splitting it among multiple entries.",
// );

const RENDER_FLASH_MSG = sprintf(
  s__(
    'math|The math in this entry is taking too long to render and may not be displayed as expected. For performance reasons, math blocks are also limited to %{maxChars} characters. Consider splitting up large formulae, splitting math blocks among multiple entries, or using an image instead.',
  ),
  { maxChars: MAX_MATH_CHARS },
);

// Wait for the browser to reflow the layout. Reflowing SVG takes time.
// This has to wrap the inner function, otherwise IE/Edge throw "invalid calling object".
const waitForReflow = (fn) => {
  window.requestIdleCallback(fn);
};

/**
 * Renders math blocks sequentially while protecting against DoS attacks. Math blocks have a maximum character limit of MAX_MATH_CHARS. If rendering math takes longer than MAX_RENDER_TIME_MS, all subsequent math blocks are skipped and an error message is shown.
 */
class SafeMathRenderer {
  /*
  How this works:

  The performance bottleneck in rendering math is in the browser trying to reflow the generated SVG.
  During this time, the JS is blocked and the page becomes unresponsive.
  We want to render math blocks one by one until a certain time is exceeded, after which we stop
  rendering subsequent math blocks, to protect against DoS. However, browsers do reflowing in an
  asynchronous task, so we can't time it synchronously.

  SafeMathRenderer essentially does the following:
  1. Replaces all math blocks with placeholders so that they're not mistakenly rendered twice.
  2. Places each placeholder element in a queue.
  3. Renders the element at the head of the queue and waits for reflow.
  4. After reflow, gets the elapsed time since step 3 and repeats step 3 until the queue is empty.
   */
  queue = [];
  totalMS = 0;

  constructor(elements, katex) {
    this.elements = elements;
    this.katex = katex;

    this.renderElement = this.renderElement.bind(this);
    this.render = this.render.bind(this);
    this.attachEvents = this.attachEvents.bind(this);
  }

  renderElement(chosenEl) {
    if (!this.queue.length && !chosenEl) {
      return;
    }

    const el = chosenEl || this.queue.shift();
    const forceRender = Boolean(chosenEl);
    const text = el.textContent;

    el.removeAttribute('style');
    if (!forceRender && (this.totalMS >= MAX_RENDER_TIME_MS || text.length > MAX_MATH_CHARS)) {
      // Show unrendered math code
      const wrapperElement = document.createElement('div');
      const codeElement = document.createElement('pre');

      codeElement.className = 'code';
      codeElement.textContent = el.textContent;

      const parentNode = el.parentNode;
      parentNode.replaceChild(wrapperElement, el);

      const html = `
          <div class="alert gl-alert gl-alert-warning alert-dismissible lazy-render-math-container js-lazy-render-math-container fade show" role="alert">
            <div>
              <div class="display-flex">
                <div>${__(
                  'Warning: Displaying this math block might cause performance issues on this page.',
                )}</div>
                <div class="gl-alert-actions">
                  <button class="js-lazy-render-math btn gl-alert-action btn-warning btn-md gl-button">Display</button>
                </div>
              </div>
              <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
          </div>
          `;

      if (!wrapperElement.classList.contains('lazy-alert-shown')) {
        wrapperElement.innerHTML = html;
        wrapperElement.prepend(codeElement);
        wrapperElement.classList.add('lazy-alert-shown');
      }

      // Render the next math
      this.renderElement();
    } else {
      this.startTime = Date.now();
      let displayContainer = el;
      if (el.tagName === 'PRE') {
        displayContainer = el.parentElement;
        displayContainer;
      }
      try {
        displayContainer.innerHTML = this.katex.renderToString(text, {
          displayMode: el.getAttribute('data-math-style') === 'display',
          throwOnError: true,
          maxSize: 20,
          maxExpand: 20,
        });
      } catch (e) {
        // Don't show a flash for now because it would override an existing flash message
        el.textContent = s__('math|There was an error rendering this math block');
        // el.style.color = '#d00';
        el.className = 'katex-error';
      }

      // Give the browser time to reflow the svg
      waitForReflow(() => {
        const deltaTime = differenceInMilliseconds(this.startTime);
        this.totalMS += deltaTime;

        this.renderElement();
      });
    }
  }

  render() {
    // Replace math blocks with a placeholder so they aren't rendered twice
    this.elements.forEach((el) => {
      const placeholder = document.createElement('span');
      placeholder.style.display = 'none';
      placeholder.setAttribute('data-math-style', el.getAttribute('data-math-style'));
      placeholder.textContent = el.textContent;
      el.parentNode.replaceChild(placeholder, el);
      this.queue.push(placeholder);
    });

    // If we wait for the browser thread to settle down a bit, math rendering becomes 5-10x faster
    // and less prone to timeouts.
    setTimeout(this.renderElement, 400);
  }

  attachEvents() {
    $(document.body).on('click', '.js-lazy-render-math', (event) => {
      const parent = $(event.target).closest('.js-lazy-render-math-container');
      const pre = parent.prev();

      parent.remove();

      this.renderElement(pre[0]);
    });
  }
}

export default function renderMath($els) {
  if (!$els.length) return;
  Promise.all([
    import(/* webpackChunkName: 'katex' */ 'katex'),
    import(/* webpackChunkName: 'katex' */ 'katex/dist/katex.min.css'),
  ])
    .then(([katex]) => {
      const renderer = new SafeMathRenderer($els.get(), katex);
      renderer.render();
      renderer.attachEvents();
    })
    .catch(() => {});
}
