import Vue from 'vue';
import setConfigs from '@gitlab/ui/dist/config';
import Translate from '~/vue_shared/translate';
import GlFeatureFlagsPlugin from '~/vue_shared/gl_feature_flags_plugin';

import { addSubscription, removeSubscription, getLocation } from '~/jira_connect/api';
import JiraConnectApp from './components/app.vue';
import createStore from './store';
import { SET_ALERT } from './store/mutation_types';

const store = createStore();

const reqComplete = () => {
  AP.navigator.reload();
};

const reqFailed = (res, fallbackErrorMessage) => {
  const { error = fallbackErrorMessage } = res || {};

  store.commit(SET_ALERT, { message: error, variant: 'danger' });
};

const updateSignInLinks = async () => {
  const location = await getLocation();
  Array.from(document.querySelectorAll('.js-jira-connect-sign-in')).forEach((el) => {
    const updatedLink = `${el.getAttribute('href')}?return_to=${location}`;
    el.setAttribute('href', updatedLink);
  });
};

const initRemoveSubscriptionButtonHandlers = () => {
  Array.from(document.querySelectorAll('.js-jira-connect-remove-subscription')).forEach((el) => {
    el.addEventListener('click', function onRemoveSubscriptionClick(e) {
      e.preventDefault();

      const removePath = e.target.getAttribute('href');
      removeSubscription(removePath)
        .then(reqComplete)
        .catch((err) =>
          reqFailed(err.response.data, 'Failed to remove namespace. Please try again.'),
        );
    });
  });
};

const initAddSubscriptionFormHandler = () => {
  const formEl = document.querySelector('#add-subscription-form');
  if (!formEl) {
    return;
  }

  formEl.addEventListener('submit', function onAddSubscriptionForm(e) {
    e.preventDefault();

    const addPath = e.target.getAttribute('action');
    const namespace = (e.target.querySelector('#namespace-input') || {}).value;

    addSubscription(addPath, namespace)
      .then(reqComplete)
      .catch((err) => reqFailed(err.response.data, 'Failed to add namespace. Please try again.'));
  });
};

export async function initJiraConnect() {
  initAddSubscriptionFormHandler();
  initRemoveSubscriptionButtonHandlers();

  await updateSignInLinks();

  const el = document.querySelector('.js-jira-connect-app');
  if (!el) {
    return null;
  }

  setConfigs();
  Vue.use(Translate);
  Vue.use(GlFeatureFlagsPlugin);

  const { groupsPath, subscriptionsPath, usersPath } = el.dataset;

  return new Vue({
    el,
    store,
    provide: {
      groupsPath,
      subscriptionsPath,
      usersPath,
    },
    render(createElement) {
      return createElement(JiraConnectApp);
    },
  });
}

document.addEventListener('DOMContentLoaded', initJiraConnect);
