import Vue from 'vue';
import Vuex from 'vuex';
import setConfigs from '@gitlab/ui/dist/config';
import Translate from '~/vue_shared/translate';
import GlFeatureFlagsPlugin from '~/vue_shared/gl_feature_flags_plugin';

import JiraConnectApp from './components/app.vue';
import { addSubscription, removeSubscription } from '~/jira_connect/api';
import createStore from './store';
import { SET_ERROR_MESSAGE } from './store/mutation_types';

Vue.use(Vuex);

const store = createStore();

const reqComplete = () => {
  AP.navigator.reload();
};

const reqFailed = (res, fallbackErrorMessage) => {
  const { error = fallbackErrorMessage } = res || {};

  store.commit(SET_ERROR_MESSAGE, error);
};

const updateSignInLinks = () => {
  if (typeof AP.getLocation === 'function') {
    AP.getLocation((location) => {
      Array.from(document.querySelectorAll('.js-jira-connect-sign-in')).forEach((el) => {
        const updatedLink = `${el.getAttribute('href')}?return_to=${location}`;
        el.setAttribute('href', updatedLink);
      });
    });
  }
};

/**
 * Initialize form handlers for the Jira Connect app
 */
const initJiraFormHandlers = () => {
  document
    .querySelector('#add-subscription-form')
    .addEventListener('submit', function onAddSubscriptionForm(e) {
      e.preventDefault();

      const addPath = e.target.getAttribute('action');
      const namespace = e.target.querySelector('#namespace-input').getAttribute('value');

      addSubscription(addPath, namespace)
        .then(reqComplete)
        .catch((err) => reqFailed(err.response.data, 'Failed to add namespace. Please try again.'));
    });

  document
    .querySelector('.remove-subscription')
    .addEventListener('click', function onRemoveSubscriptionClick(e) {
      e.preventDefault();

      const removePath = e.target.getAttribute('href');
      removeSubscription(removePath)
        .then(reqComplete)
        .catch((err) =>
          reqFailed(err.response.data, 'Failed to remove namespace. Please try again.'),
        );
    });
};

function initJiraConnect() {
  initJiraFormHandlers();
  updateSignInLinks();

  const el = document.querySelector('.js-jira-connect-app');
  if (!el) {
    return null;
  }

  setConfigs();
  Vue.use(Translate);
  Vue.use(GlFeatureFlagsPlugin);

  const { groupsPath } = el.dataset;

  return new Vue({
    el,
    store,
    provide: {
      groupsPath,
    },
    render(createElement) {
      return createElement(JiraConnectApp);
    },
  });
}

document.addEventListener('DOMContentLoaded', initJiraConnect);
