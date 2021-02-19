import isFunction from 'lodash/isFunction';

const DELAY_ON_HOVER = 100;

let mouseOverTimer;

const InstantLoadDirective = {
  bind(el, { value: preloadHandler }) {
    if (!isFunction(preloadHandler)) {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      throw TypeError('Directive value must be a function');
    }

    const mouseOutHandler = () => {
      if (mouseOverTimer) {
        clearTimeout(mouseOverTimer);
        mouseOverTimer = undefined;
      }
    };

    const mouseOverHandler = () => {
      el.addEventListener('mouseout', mouseOutHandler, { passive: true });

      mouseOverTimer = setTimeout(() => {
        preloadHandler(el);

        // Only execute completely once
        el.removeEventListener('mouseover', mouseOverHandler, true);
        el.removeEventListener('mouseout', mouseOutHandler);

        mouseOverTimer = undefined;
      }, DELAY_ON_HOVER);
    };

    el.preloadHandler = preloadHandler;

    el.addEventListener('mouseover', mouseOverHandler, {
      capture: true,
      passive: true,
    });
  },
  unbind(el) {
    if (el.preloadHandler) {
      delete el.preloadHandler;
    }
  },
};

export default InstantLoadDirective;
