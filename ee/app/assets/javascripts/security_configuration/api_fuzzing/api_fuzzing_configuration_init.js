import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import { apolloProvider } from './graphql/provider';
import ApiFuzzingApp from './components/app.vue';

export const initApiFuzzingConfiguration = () => {
  const el = document.querySelector('.js-api-fuzzing-configuration');

  if (!el) {
    return undefined;
  }

  const {
    fullPath,
    apiFuzzingDocumentationPath,
    apiFuzzingAuthenticationDocumentationPath,
    ciVariablesDocumentationPath,
    projectCiSettingsPath,
  } = el.dataset;
  const canSetProjectCiVariables = parseBoolean(el.dataset.canSetProjectCiVariables);

  return new Vue({
    el,
    apolloProvider,
    provide: {
      fullPath,
      apiFuzzingDocumentationPath,
      apiFuzzingAuthenticationDocumentationPath,
      ciVariablesDocumentationPath,
      projectCiSettingsPath,
      canSetProjectCiVariables,
    },
    render(createElement) {
      return createElement(ApiFuzzingApp);
    },
  });
};
