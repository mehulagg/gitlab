import Vue from 'vue';
import VueApollo from 'vue-apollo';
import JobsTable from '~/jobs/components/table/jobs_table.vue';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default (containerId = 'js-jobs-table') => {
  const containerEl = document.getElementById(containerId);

  if (!containerEl) {
    return false;
  }

  const { fullPath } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    apolloProvider,
    provide: {
      fullPath,
    },
    render(createElement) {
      return createElement(JobsTable);
    },
  });
};
