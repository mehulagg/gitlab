import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import pipelineGraph from './components/graph/graph_component.vue';
import createDagApp from './pipeline_details_dag';
import GraphBundleMixin from './mixins/graph_pipeline_bundle_mixin';
import PipelinesMediator from './pipeline_details_mediator';
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

const createPipelinesDetailApp = mediator => {
  if (!document.querySelector(SELECTORS.PIPELINE_GRAPH)) {
    return;
  }
  // eslint-disable-next-line no-new
  new Vue({
    el: SELECTORS.PIPELINE_GRAPH,
    components: {
      pipelineGraph,
    },
    mixins: [GraphBundleMixin],
    data() {
      return {
        mediator,
      };
    },
    render(createElement) {
      return createElement('pipeline-graph', {
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
  const { dataset } = document.querySelector(SELECTORS.PIPELINE_DETAILS);
  const mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
  mediator.fetchPipeline();

  createPipelinesDetailApp(mediator);
  createPipelineHeaderApp();
  createTestDetails();
  createDagApp();
};
