import Vue from 'vue';
import EpicFilteredSearch from 'ee_component/boards/components/epic_filtered_search.vue';
import store from '~/boards/stores';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
// eslint-disable-next-line import/no-deprecated
import { urlParamsToObject } from '~/lib/utils/url_utility';

export default (apolloProvider) => {
  const el = document.getElementById('js-board-filtered-search');
  // eslint-disable-next-line import/no-deprecated
  const rawFilterParams = urlParamsToObject(window.location.search);
  const initialFilterParams = {
    ...convertObjectPropsToCamelCase(rawFilterParams, {}),
  };

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    provide: {
      initialFilterParams,
    },
    store, // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/324094
    apolloProvider,
    render: (createElement) =>
      createElement(EpicFilteredSearch, {
        props: { fullPath: store.state?.fullPath || '', boardType: store.state?.boardType || '' },
      }),
  });
};
