import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import store from './store';
import ErrorDetails from './components/error_details.vue';
import csrf from '~/lib/utils/csrf';

Vue.use(VueApollo);

export default () => {
  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-error_details',
    apolloProvider,
    components: {
      ErrorDetails,
    },
    store,
    render(createElement) {
      const domEl = document.querySelector(this.$options.el);
      const {
        issueId,
        projectPath,
        issueUpdatePath,
        issueStackTracePath,
        previewMarkdownPath,
        projectIssuesPath,
      } = domEl.dataset;

      return createElement('error-details', {
        props: {
          issueId,
          projectPath,
          issueUpdatePath,
          issueStackTracePath,
          previewMarkdownPath,
          projectIssuesPath,
          csrfToken: csrf.token,
        },
      });
    },
  });
};
