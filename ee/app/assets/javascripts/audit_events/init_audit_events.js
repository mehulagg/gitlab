import Vue from 'vue';

import { convertObjectPropsToCamelCase, parseBoolean } from '~/lib/utils/common_utils';

import AuditEventsApp from './components/audit_events_app.vue';
import createStore from './store';

export default selector => {
  const el = document.querySelector(selector);
  const { events, isLastPage, filterTokenOptions, exportUrl } = el.dataset;

  const store = createStore();
  store.dispatch('initializeAuditEvents');

  return new Vue({
    el,
    store,
    render: createElement =>
      createElement(AuditEventsApp, {
        props: {
          events: JSON.parse(events),
          isLastPage: parseBoolean(isLastPage),
          filterTokenOptions: JSON.parse(filterTokenOptions).map(filterTokenOption =>
            convertObjectPropsToCamelCase(filterTokenOption),
          ),
          exportUrl,
        },
      }),
  });
};
