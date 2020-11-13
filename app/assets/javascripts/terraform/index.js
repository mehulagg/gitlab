import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import TerraformList from './components/terraform_list.vue';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('#js-terraform-list');

  if (!el) {
    return null;
  }

  const defaultClient = createDefaultClient();

  const { emptyStateImage, projectPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    render(createElement) {
      return createElement(TerraformList, {
        props: {
          emptyStateImage,
          projectPath,
        },
      });
    },
  });
};
