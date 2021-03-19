import { omitBy, isUndefined } from 'lodash';
import { TRACKING_CONTEXT_SCHEMA } from '~/experimentation/constants';
import { getExperimentData } from '~/experimentation/utils';

const standardContext = { ...window.gl?.snowplowStandardContext };

export const STANDARD_CONTEXT = {
  schema: standardContext.schema,
  data: {
    ...(standardContext.data || {}),
    source: 'gitlab-javascript',
  },
};

const DEFAULT_SNOWPLOW_OPTIONS = {
  namespace: 'gl',
  hostname: window.location.hostname,
  cookieDomain: window.location.hostname,
  appId: '',
  userFingerprint: false,
  respectDoNotTrack: true,
  forceSecureTracker: true,
  eventMethod: 'post',
  contexts: { webPage: true, performanceTiming: true },
  formTracking: false,
  linkClickTracking: false,
  pageUnloadTimer: 10,
};

const createEventPayload = (el, { suffix = '' } = {}) => {
  const action = el.dataset.trackEvent + (suffix || '');
  let value = el.dataset.trackValue || el.value || undefined;
  if (el.type === 'checkbox' && !el.checked) value = false;

  let context = el.dataset.trackContext;
  if (el.dataset.trackExperiment) {
    const data = getExperimentData(el.dataset.trackExperiment);
    if (data) context = { schema: TRACKING_CONTEXT_SCHEMA, data };
  }

  const data = {
    label: el.dataset.trackLabel,
    property: el.dataset.trackProperty,
    value,
    context,
  };

  return {
    action,
    data: omitBy(data, isUndefined),
  };
};

const eventHandler = (e, func, opts = {}) => {
  const el = e.target.closest('[data-track-event]');

  if (!el) return;

  const { action, data } = createEventPayload(el, opts);
  func(opts.category, action, data);
};

const eventHandlers = (category, func) => {
  const handler = (opts) => (e) => eventHandler(e, func, { ...{ category }, ...opts });
  const handlers = [];
  handlers.push({ name: 'click', func: handler() });
  handlers.push({ name: 'show.bs.dropdown', func: handler({ suffix: '_show' }) });
  handlers.push({ name: 'hide.bs.dropdown', func: handler({ suffix: '_hide' }) });
  return handlers;
};

const dispatchEvent = (category = document.body.dataset.page, action = 'generic', data = {}) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  if (!category) throw new Error('Tracking: no category provided for tracking.');

  const { label, property, value } = data;
  const contexts = [STANDARD_CONTEXT];

  if (data.context) {
    contexts.push(data.context);
  }

  return window.snowplow('trackStructEvent', category, action, label, property, value, contexts);
};

export default class Tracking {
  static queuedEvents = [];
  static initialized = false;

  static trackable() {
    return !['1', 'yes'].includes(
      window.doNotTrack || navigator.doNotTrack || navigator.msDoNotTrack,
    );
  }

  static flushPendingEvents() {
    this.initialized = true;

    while (this.queuedEvents.length) {
      dispatchEvent(...this.queuedEvents.shift());
    }
  }

  static enabled() {
    return typeof window.snowplow === 'function' && this.trackable();
  }

  static event(...eventData) {
    if (!this.enabled()) return false;

    if (!this.initialized) {
      this.queuedEvents.push(eventData);
      return false;
    }

    return dispatchEvent(...eventData);
  }

  static bindDocument(category = document.body.dataset.page, parent = document) {
    if (!this.enabled() || parent.trackingBound) return [];

    // eslint-disable-next-line no-param-reassign
    parent.trackingBound = true;

    const handlers = eventHandlers(category, (...args) => this.event(...args));
    handlers.forEach((event) => parent.addEventListener(event.name, event.func));
    return handlers;
  }

  static trackLoadEvents(category = document.body.dataset.page, parent = document) {
    if (!this.enabled()) return [];

    const loadEvents = parent.querySelectorAll('[data-track-event="render"]');

    loadEvents.forEach((element) => {
      const { action, data } = createEventPayload(element);
      this.event(category, action, data);
    });

    return loadEvents;
  }

  static mixin(opts = {}) {
    return {
      computed: {
        trackingCategory() {
          const localCategory = this.tracking ? this.tracking.category : null;
          return localCategory || opts.category;
        },
        trackingOptions() {
          return { ...opts, ...this.tracking };
        },
      },
      methods: {
        track(action, data = {}) {
          const category = data.category || this.trackingCategory;
          const options = {
            ...this.trackingOptions,
            ...data,
          };
          Tracking.event(category, action, options);
        },
      },
    };
  }
}

export function initUserTracking() {
  if (!Tracking.enabled()) return;

  const opts = { ...DEFAULT_SNOWPLOW_OPTIONS, ...window.snowplowOptions };
  window.snowplow('newTracker', opts.namespace, opts.hostname, opts);

  document.dispatchEvent(new Event('SnowplowInitialized'));
  Tracking.flushPendingEvents();
}

export function initDefaultTrackers() {
  if (!Tracking.enabled()) return;

  window.snowplow('enableActivityTracking', 30, 30);
  // must be after enableActivityTracking
  window.snowplow('trackPageView', null, [STANDARD_CONTEXT]);

  if (window.snowplowOptions.formTracking) window.snowplow('enableFormTracking');
  if (window.snowplowOptions.linkClickTracking) window.snowplow('enableLinkClickTracking');

  Tracking.bindDocument();
  Tracking.trackLoadEvents();
}
