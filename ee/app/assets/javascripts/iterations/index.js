import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import IterationCadenceForm from './components/iteration_cadence_form.vue';
import IterationForm from './components/iteration_form.vue';
import IterationReport from './components/iteration_report.vue';
import Iterations from './components/iterations.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(
    {},
    {
      batchMax: 1,
    },
  ),
});

export function initIterationsList(namespaceType) {
  const el = document.querySelector('.js-iterations-list');

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(Iterations, {
        props: {
          fullPath: el.dataset.fullPath,
          canAdmin: parseBoolean(el.dataset.canAdmin),
          namespaceType,
          newIterationPath: el.dataset.newIterationPath,
        },
      });
    },
  });
}

export function initIterationForm() {
  const el = document.querySelector('.js-iteration-new');

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(IterationForm, {
        props: {
          groupPath: el.dataset.groupFullPath,
          previewMarkdownPath: el.dataset.previewMarkdownPath,
          iterationsListPath: el.dataset.iterationsListPath,
        },
      });
    },
  });
}

export function initIterationReport({ namespaceType, initiallyEditing } = {}) {
  const el = document.querySelector('.js-iteration');

  const {
    fullPath,
    hasScopedLabelsFeature,
    iterationId,
    labelsFetchPath,
    editIterationPath,
    previewMarkdownPath,
    svgPath,
  } = el.dataset;
  const canEdit = parseBoolean(el.dataset.canEdit);

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(IterationReport, {
        props: {
          fullPath,
          hasScopedLabelsFeature: parseBoolean(hasScopedLabelsFeature),
          iterationId,
          labelsFetchPath,
          canEdit,
          editIterationPath,
          namespaceType,
          previewMarkdownPath,
          svgPath,
          initiallyEditing,
        },
      });
    },
  });
}

export function initCadenceForm() {
  const el = document.querySelector('.js-iteration-cadence-form');

  if (!el) {
    return null;
  }

  const { groupFullPath: groupPath, cadenceId, cadenceListPath } = el;

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(IterationCadenceForm, {
        props: {
          groupPath,
          cadenceId,
          cadenceListPath,
        },
      });
    },
  });
}
