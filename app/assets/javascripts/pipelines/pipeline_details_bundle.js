import Vue from 'vue';
import { deprecatedCreateFlash as Flash } from '~/flash';
import Translate from '~/vue_shared/translate';
import { __ } from '~/locale';
import PipelineGraphLegacy from './components/graph/graph_component_legacy.vue';
import createDagApp from './pipeline_details_dag';
import GraphBundleMixin from './mixins/graph_pipeline_bundle_mixin';
import TestReports from './components/test_reports/test_reports.vue';
import createTestReportsStore from './stores/test_reports';
import { reportToSentry } from './components/graph/utils';

Vue.use(Translate);

const SELECTORS = {
  PIPELINE_DETAILS: '.js-pipeline-details-vue',
  PIPELINE_GRAPH: '#js-pipeline-graph-vue',
  PIPELINE_HEADER: '#js-pipeline-header-vue',
  PIPELINE_TESTS: '#js-pipeline-tests-detail',
};

const createLegacyPipelinesDetailApp = (mediator) => {
  if (!document.querySelector(SELECTORS.PIPELINE_GRAPH)) {
    return;
  }
  // eslint-disable-next-line no-new
  new Vue({
    el: SELECTORS.PIPELINE_GRAPH,
    components: {
      PipelineGraphLegacy,
    },
    mixins: [GraphBundleMixin],
    data() {
      return {
        mediator,
      };
    },
    errorCaptured(err, _vm, info) {
      reportToSentry('pipeline_details_bundle_legacy_details', `error: ${err}, info: ${info}`);
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
          onResetDownstream: (parentPipeline, pipeline) =>
            this.resetDownstreamPipelines(parentPipeline, pipeline),
          onClickUpstreamPipeline: (pipeline) => this.clickUpstreamPipeline(pipeline),
          onClickDownstreamPipeline: (pipeline) => this.clickDownstreamPipeline(pipeline),
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

export default async function () {
  createTestDetails();
  createDagApp();

  const canShowNewPipelineDetails =
    gon.features.graphqlPipelineDetails || gon.features.graphqlPipelineDetailsUsers;

  const { dataset } = document.querySelector(SELECTORS.PIPELINE_DETAILS);
  let mediator;

  if (!canShowNewPipelineDetails) {
    try {
      const { default: PipelinesMediator } = await import(
        /* webpackChunkName: 'PipelinesMediator' */ './pipeline_details_mediator'
      );
      mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
      mediator.fetchPipeline();
    } catch {
      Flash(__('An error occurred while loading the pipeline.'));
    }
  }

  if (canShowNewPipelineDetails) {
    try {
      const { createPipelinesDetailApp } = await import(
        /* webpackChunkName: 'createPipelinesDetailApp' */ './pipeline_details_graph'
      );

      const { pipelineProjectPath, pipelineIid } = dataset;
      createPipelinesDetailApp(SELECTORS.PIPELINE_GRAPH, pipelineProjectPath, pipelineIid);
    } catch {
      Flash(__('An error occurred while loading the pipeline.'));
    }
  } else {
    createLegacyPipelinesDetailApp(mediator);
  }

  try {
    const { createPipelineHeaderApp } = await import(
      /* webpackChunkName: 'createPipelineHeaderApp' */ './pipeline_details_header'
    );
    createPipelineHeaderApp(SELECTORS.PIPELINE_HEADER);
  } catch {
    Flash(__('An error occurred while loading a section of this page.'));
  }
}
