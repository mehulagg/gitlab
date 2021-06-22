import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import AdminUsersApp from './components/app.vue';
import UserActions from './components/user_actions.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({}, { assumeImmutableResults: true }),
});

export const initAdminUsersApp = (el = document.querySelector('#js-admin-users-app')) => {
  if (!el) {
    return false;
  }

  const { users, paths } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render: (createElement) =>
      createElement(AdminUsersApp, {
        props: {
          users: convertObjectPropsToCamelCase(JSON.parse(users), { deep: true }),
          paths: convertObjectPropsToCamelCase(JSON.parse(paths)),
        },
      }),
  });
};

export const initAdminUserActions = () => {
  const el = document.querySelector('#js-admin-user-actions');

  if (!el) {
    return false;
  }

  const { user, paths } = el.dataset;

  return new Vue({
    el,
    render: (createElement) =>
      createElement(UserActions, {
        props: {
          user: convertObjectPropsToCamelCase(JSON.parse(user), { deep: true }),
          paths: convertObjectPropsToCamelCase(JSON.parse(paths)),
          showImpersonateButton: true,
          showButtonLabels: true,
        },
      }),
  });
};
