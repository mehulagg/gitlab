import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlToast } from '@gitlab/ui';
import { doesHashExistInUrl } from '~/lib/utils/url_utility';
import createDefaultClient from '~/lib/graphql';

import {
  parseBoolean,
  historyReplaceState,
  buildUrlWithCurrentLocation,
} from '~/lib/utils/common_utils';
import { __ } from '~/locale';

import PipelinesStore from '../../../../pipelines/stores/pipelines_store';
import pipelinesComponent from '../../../../pipelines/components/pipelines_list/pipelines.vue';
import pipelinesComponentNew from '../../../../pipelines/components/pipelines_list_new/pipelines.vue';
import Translate from '../../../../vue_shared/translate';

Vue.use(Translate);
Vue.use(GlToast);
Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

const el = document.getElementById('pipelines-list-vue');

const createLegacyList = () => {
  return new Vue({
    el: '#pipelines-list-vue',
    components: {
      pipelinesComponent,
    },
    data() {
      return {
        store: new PipelinesStore(),
      };
    },
    created() {
      this.dataset = document.querySelector(this.$options.el).dataset;

      if (doesHashExistInUrl('delete_success')) {
        this.$toast.show(__('The pipeline has been deleted'));
        historyReplaceState(buildUrlWithCurrentLocation());
      }
    },
    render(createElement) {
      return createElement('pipelines-component', {
        props: {
          store: this.store,
          endpoint: this.dataset.endpoint,
          pipelineScheduleUrl: this.dataset.pipelineScheduleUrl,
          helpPagePath: this.dataset.helpPagePath,
          emptyStateSvgPath: this.dataset.emptyStateSvgPath,
          errorStateSvgPath: this.dataset.errorStateSvgPath,
          noPipelinesSvgPath: this.dataset.noPipelinesSvgPath,
          autoDevopsPath: this.dataset.helpAutoDevopsPath,
          newPipelinePath: this.dataset.newPipelinePath,
          canCreatePipeline: parseBoolean(this.dataset.canCreatePipeline),
          hasGitlabCi: parseBoolean(this.dataset.hasGitlabCi),
          ciLintPath: this.dataset.ciLintPath,
          resetCachePath: this.dataset.resetCachePath,
          projectId: this.dataset.projectId,
          params: JSON.parse(this.dataset.params),
        },
      });
    },
  });
};

const createList = () => {
  return new Vue({
    el: '#pipelines-list-vue',
    components: {
      pipelinesComponentNew,
    },
    data() {
      return {
        store: new PipelinesStore(),
      };
    },
    apolloProvider,
    render(createElement) {
      return createElement('pipelines-component-new', {
        props: {
          store: this.store,
          endpoint: el.dataset.endpoint,
          pipelineScheduleUrl: el.dataset.pipelineScheduleUrl,
          helpPagePath: el.dataset.helpPagePath,
          emptyStateSvgPath: el.dataset.emptyStateSvgPath,
          errorStateSvgPath: el.dataset.errorStateSvgPath,
          noPipelinesSvgPath: el.dataset.noPipelinesSvgPath,
          autoDevopsPath: el.dataset.helpAutoDevopsPath,
          newPipelinePath: el.dataset.newPipelinePath,
          canCreatePipeline: parseBoolean(el.dataset.canCreatePipeline),
          hasGitlabCi: parseBoolean(el.dataset.hasGitlabCi),
          ciLintPath: el.dataset.ciLintPath,
          resetCachePath: el.dataset.resetCachePath,
          projectId: el.dataset.projectId,
          params: JSON.parse(el.dataset.params),
          pipelinesProjectPath: el.dataset.pipelineProjectPath,
        },
      });
    },
  });
};

if (gon.features?.graphqlPipelinesList) {
  createList();
} else {
  createLegacyList();
}
