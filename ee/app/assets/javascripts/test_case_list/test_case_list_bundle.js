import Vue from 'vue';
import VueApollo from 'vue-apollo';

import createDefaultClient from '~/lib/graphql';
import {
  urlParamsToObject,
  convertObjectPropsToCamelCase,
  parseBoolean,
} from '~/lib/utils/common_utils';

import TestCaseListApp from './components/test_case_list_root.vue';

import { TestCaseStates } from './constants';

Vue.use(VueApollo);

const initTestCaseList = ({ mountPointSelector }) => {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    canCreateTestCase,
    page = 1,
    prev = '',
    next = '',
    initialState = TestCaseStates.Opened,
    initialSortBy = 'created_desc',
  } = mountPointEl.dataset;

  const initialFilterParams = Object.assign(
    convertObjectPropsToCamelCase(urlParamsToObject(window.location.search.substring(1)), {
      dropKeys: ['scope', 'utf8', 'state', 'sort'], // These keys are unsupported/unnecessary
    }),
  );

  return new Vue({
    el: mountPointEl,
    apolloProvider,
    provide: {
      ...mountPointEl.dataset,
      canCreateTestCase: parseBoolean(canCreateTestCase),
      page: parseInt(page, 10),
      prev,
      next,
      initialState,
      initialSortBy,
    },
    render: (createElement) =>
      createElement(TestCaseListApp, {
        props: {
          initialFilterParams,
        },
      }),
  });
};

export default initTestCaseList;
