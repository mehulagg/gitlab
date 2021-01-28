import Vue from 'vue';
import VueApollo from 'vue-apollo';
import IterationDropdown from 'ee/sidebar/components/iteration_dropdown.vue';
import createDefaultClient from '~/lib/graphql';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

Vue.use(VueApollo);

export default function () {
  const el = document.querySelector('#js-iteration-dropdown');
  const iterationField = document.getElementById('issue_iteration_id');

  if (!el || !iterationField) {
    return false;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const { fullPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    methods: {
      handleIterationSelect(iteration) {
        const unselectedIterationValue = '0';
        const id = !iteration?.id ? unselectedIterationValue : getIdFromGraphQLId(iteration.id);

        iterationField.setAttribute('value', id);
      },
    },
    render(createElement) {
      return createElement(IterationDropdown, {
        props: {
          fullPath,
        },
        on: {
          onIterationSelect: this.handleIterationSelect.bind(this),
        },
      });
    },
  });
}
