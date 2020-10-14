import Vue from 'vue';
import { deprecatedCreateFlash as Flash } from '~/flash';
import Translate from '~/vue_shared/translate';
import { __ } from '~/locale';
import { setUrlFragment, redirectTo } from '~/lib/utils/url_utility';
import pipelineGraphLegacy from './components/graph/graph_component_legacy.vue';
import createDagApp from './pipeline_details_dag';
import createPipelinesDetailApp from './pipeline_details_graph';
import GraphBundleMixin from './mixins/graph_pipeline_bundle_mixin';
import PipelinesMediator from './pipeline_details_mediator';
import legacyPipelineHeader from './components/legacy_header_component.vue';
import eventHub from './event_hub';
import TestReports from './components/test_reports/test_reports.vue';
import createTestReportsStore from './stores/test_reports';
import { createPipelineHeaderApp } from './pipeline_details_header';

Vue.use(Translate);

const SELECTORS = {
  PIPELINE_DETAILS: '.js-pipeline-details-vue',
  PIPELINE_GRAPH: '#js-pipeline-graph-vue',
  PIPELINE_HEADER: '#js-pipeline-header-vue',
  PIPELINE_TESTS: '#js-pipeline-tests-detail',
};

// Replace with actual feature flag check
const showNewGraph = true;

const createLegacyPipelinesDetailApp = mediator => {

  console.log(mediator);

  if (!document.querySelector(SELECTORS.PIPELINE_GRAPH)) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: SELECTORS.PIPELINE_GRAPH,
    components: {
      pipelineGraphLegacy,
    },
    mixins: [GraphBundleMixin],
    data() {
      return {
        mediator,
      };
    },
    render(createElement) {
      return createElement('pipeline-graph-legacy', {
        props: {
          isLoading: this.mediator.state.isLoading,
          pipeline: this.mediator.store.state.pipeline,
          mediator: this.mediator,
        },
        on: {
          refreshPipelineGraph: this.requestRefreshPipelineGraph,
          onResetTriggered: (parentPipeline, pipeline) =>
            this.resetTriggeredPipelines(parentPipeline, pipeline),
          onClickTriggeredBy: pipeline => this.clickTriggeredByPipeline(pipeline),
          onClickTriggered: pipeline => this.clickTriggeredPipeline(pipeline),
        },
      });
    },
  });
};

const createLegacyPipelineHeaderApp = mediator => {
  if (!document.querySelector(SELECTORS.PIPELINE_HEADER)) {
    return;
  }
  // eslint-disable-next-line no-new
  new Vue({
    el: SELECTORS.PIPELINE_HEADER,
    components: {
      legacyPipelineHeader,
    },
    data() {
      return {
        mediator,
      };
    },
    created() {
      eventHub.$on('headerPostAction', this.postAction);
      eventHub.$on('headerDeleteAction', this.deleteAction);
    },
    beforeDestroy() {
      eventHub.$off('headerPostAction', this.postAction);
      eventHub.$off('headerDeleteAction', this.deleteAction);
    },
    methods: {
      postAction(path) {
        this.mediator.service
          .postAction(path)
          .then(() => this.mediator.refreshPipeline())
          .catch(() => Flash(__('An error occurred while making the request.')));
      },
      deleteAction(path) {
        this.mediator.stopPipelinePoll();
        this.mediator.service
          .deleteAction(path)
          .then(({ request }) => redirectTo(setUrlFragment(request.responseURL, 'delete_success')))
          .catch(() => Flash(__('An error occurred while deleting the pipeline.')));
      },
    },
    render(createElement) {
      return createElement('legacy-pipeline-header', {
        props: {
          isLoading: this.mediator.state.isLoading,
          pipeline: this.mediator.store.state.pipeline,
        },
      });
    },
  });
};

const createTestDetails = () => {
  const el = document.querySelector(SELECTORS.PIPELINE_TESTS);
  const { summaryEndpoint, suiteEndpoint } = el?.dataset || {};
  const testReportsStore = createTestReportsStore({
    summaryEndpoint,
    suiteEndpoint,
  });

  // eslint-disable-next-line no-new
  new Vue({
    el,
    components: {
      TestReports,
    },
    store: testReportsStore,
    render(createElement) {
      return createElement('test-reports');
    },
  });
};

export default () => {

  let mediator;
  const { dataset } = document.querySelector(SELECTORS.PIPELINE_DETAILS);

  // if we are showing at least one legacy app, setup and call mediator
  if (!gon.features.graphqlPipelineHeader || !showNewGraph) {
    // move conditional import here too
    mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
    mediator.fetchPipeline();
  }

  if (gon.features.graphqlPipelineHeader) {
    createPipelineHeaderApp(SELECTORS.PIPELINE_HEADER);
  } else {
    createLegacyPipelineHeaderApp(mediator);
  }

  if (showNewGraph) {
    const { pipelineProjectPath, pipelineIid } = dataset;
    createPipelinesDetailApp(SELECTORS.PIPELINE_DETAILS, pipelineProjectPath, pipelineIid);
  } else {
    createLegacyPipelinesDetailApp(mediator);
  }

  createTestDetails();
  createDagApp();
};
