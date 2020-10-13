import Vue from 'vue';
import jQuery from 'jquery';
import { toArray, isFunction } from 'lodash';
import PopoversComponent from './components/popovers.vue';

let app;

const EVENTS_MAP = {
  hover: 'mouseenter',
  click: 'click',
  focus: 'focus',
};

const DEFAULT_TRIGGER = 'hover focus';
const APP_ELEMENT_ID = 'gl-popovers-app';

const popoversApp = () => {
  if (!app) {
    const container = document.createElement('div');

    container.setAttribute('id', APP_ELEMENT_ID);
    document.body.appendChild(container);

    const Popovers = Vue.extend(PopoversComponent);

    app = new Popovers();
    app.$mount();
    document.getElementById(APP_ELEMENT_ID).appendChild(app.$el);
  }

  return app;
};

const isPopover = (node, selector) => node.matches && node.matches(selector);

const addPopovers = (elements, config) => {
  popoversApp().addPopovers(toArray(elements), config);
};

const handlePopoverEvent = (rootTarget, e, selector, config = {}) => {
  for (let { target } = e; target && target !== rootTarget; target = target.parentNode) {
    if (isPopover(target, selector)) {
      addPopovers([target], {
        show: true,
        ...config,
      });
      break;
    }
  }
};

const applyToElements = (elements, handler) => toArray(elements).forEach(handler);

const invokeBootstrapApi = (elements, method) => {
  if (isFunction(elements.popover)) {
    elements.popover(method);
  } else {
    jQuery(elements).popover(method);
  }
};

const isGlPopoversEnabled = () => Boolean(window.gon.features.glPopoversEnabled);

const popoverApiInvoker = ({ glHandler, bsHandler }) => (elements, ...params) => {
  if (isGlPopoversEnabled()) {
    applyToElements(elements, glHandler);
  } else {
    bsHandler(elements, ...params);
  }
};

export const initPopovers = (config = {}) => {
  if (isGlPopoversEnabled()) {
    const triggers = config?.triggers || DEFAULT_TRIGGER;
    const events = triggers.split(' ').map(trigger => EVENTS_MAP[trigger]);

    events.forEach(event => {
      document.addEventListener(
        event,
        e => handlePopoverEvent(document, e, config.selector, config),
        true,
      );
    });

    return popoversApp();
  }

  return invokeBootstrapApi(document.body, config);
};

export const dispose = popoverApiInvoker({
  glHandler: element => popoversApp().dispose(element),
  bsHandler: elements => invokeBootstrapApi(elements, 'dispose'),
});

export const destroy = () => {
  popoversApp().$destroy();
  app = null;
};
