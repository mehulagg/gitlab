import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
// mv to ee
export default function () {
  const el = document.querySelector('.js-iteration-dropdown');

  if (!el) {
    return false;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });
  const { groupPath, canEdit, projectPath, issueIid } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    render: (createElement) =>
      createElement('iteration-select', {}),
  });
}
