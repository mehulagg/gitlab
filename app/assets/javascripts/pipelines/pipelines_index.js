import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import {
  parseBoolean,
  historyReplaceState,
  buildUrlWithCurrentLocation,
} from '~/lib/utils/common_utils';
import { doesHashExistInUrl } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import Translate from '~/vue_shared/translate';
import Pipelines from './components/pipelines_list/pipelines.vue';
import PipelinesStore from './stores/pipelines_store';

Vue.use(Translate);
Vue.use(GlToast);

export const initPipelinesIndex = (selector = '#pipelines-list-vue') => {
  const el = document.querySelector(selector);
  if (!el) {
    return null;
  }

  const {
    endpoint,
    pipelineScheduleUrl,
    emptyStateSvgPath,
    errorStateSvgPath,
    noPipelinesSvgPath,
    newPipelinePath,
    addCiYmlPath,
    canCreatePipeline,
    hasGitlabCi,
    ciLintPath,
    resetCachePath,
    projectId,
    params,
  } = el.dataset;

  return new Vue({
    el,
    data() {
      return {
        store: new PipelinesStore(),
      };
    },
    created() {
      if (doesHashExistInUrl('delete_success')) {
        this.$toast.show(__('The pipeline has been deleted'));
        historyReplaceState(buildUrlWithCurrentLocation());
      }
    },
    render(createElement) {
      return createElement(Pipelines, {
        props: {
          store: this.store,
          endpoint,
          pipelineScheduleUrl,
          emptyStateSvgPath,
          errorStateSvgPath,
          noPipelinesSvgPath,
          newPipelinePath,
          addCiYmlPath,
          canCreatePipeline: parseBoolean(canCreatePipeline),
          hasGitlabCi: parseBoolean(hasGitlabCi),
          ciLintPath,
          resetCachePath,
          projectId,
          params: JSON.parse(params),
        },
      });
    },
  });
};
