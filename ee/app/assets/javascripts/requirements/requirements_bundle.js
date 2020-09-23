import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlToast } from '@gitlab/ui';
import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';

import RequirementsRoot from './components/requirements_root.vue';

import { FilterState } from './constants';

Vue.use(VueApollo);
Vue.use(GlToast);

export default () => {
  const el = document.getElementById('js-requirements-app');

  if (!el) {
    return false;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(
      {},
      {
        cacheConfig: {
          dataIdFromObject: object =>
            // eslint-disable-next-line no-underscore-dangle, @gitlab/require-i18n-strings
            object.__typename === 'Requirement' ? object.iid : defaultDataIdFromObject(object),
        },
      },
    ),
  });

  return new Vue({
    el,
    apolloProvider,
    components: {
      RequirementsRoot,
    },
    data() {
      const {
        filterBy,
        page,
        next,
        prev,
        textSearch,
        authorUsernames,
        sortBy,
        projectPath,
        emptyStatePath,
        opened,
        archived,
        all,
        canCreateRequirement,
        requirementsWebUrl,
      } = el.dataset;
      const stateFilterBy = filterBy ? FilterState[filterBy] : FilterState.opened;

      const OPENED = parseInt(opened, 10);
      const ARCHIVED = parseInt(archived, 10);
      const ALL = parseInt(all, 10);

      return {
        initialFilterBy: stateFilterBy,
        initialTextSearch: textSearch,
        initialAuthorUsernames: authorUsernames ? JSON.parse(authorUsernames) : [],
        initialSortBy: sortBy,
        initialRequirementsCount: {
          OPENED,
          ARCHIVED,
          ALL,
        },
        page,
        prev,
        next,
        emptyStatePath,
        projectPath,
        canCreateRequirement,
        requirementsWebUrl,
      };
    },
    render(createElement) {
      return createElement('requirements-root', {
        props: {
          projectPath: this.projectPath,
          initialFilterBy: this.initialFilterBy,
          initialTextSearch: this.initialTextSearch,
          initialAuthorUsernames: this.initialAuthorUsernames,
          initialSortBy: this.initialSortBy,
          initialRequirementsCount: this.initialRequirementsCount,
          page: parseInt(this.page, 10) || 1,
          prev: this.prev,
          next: this.next,
          emptyStatePath: this.emptyStatePath,
          canCreateRequirement: parseBoolean(this.canCreateRequirement),
          requirementsWebUrl: this.requirementsWebUrl,
        },
      });
    },
  });
};
