import Vue from 'vue';
import { deprecatedCreateFlash as Flash } from '~/flash';
import Translate from '~/vue_shared/translate';
import { __ } from '~/locale';
import { setUrlFragment, redirectTo } from '~/lib/utils/url_utility';
import pipelineGraph from './components/graph/graph_component.vue';
import createDagApp from './pipeline_details_dag';
import GraphBundleMixin from './mixins/graph_pipeline_bundle_mixin';
import legacyPipelineHeader from './components/legacy_header_component.vue';
import eventHub from './event_hub';
import TestReports from './components/test_reports/test_reports.vue';
import createTestReportsStore from './stores/test_reports';
import PipelinesMediator from './pipeline_details_mediator';
import { createPipelineHeaderApp } from './pipeline_details_header';
import { createPipelinesDetailApp } from './pipeline_details_graph';

Vue.use(Translate);

const SELECTORS = {
  PIPELINE_DETAILS: '.js-pipeline-details-vue',
  PIPELINE_GRAPH: '#js-pipeline-graph-vue',
  PIPELINE_HEADER: '#js-pipeline-header-vue',
  PIPELINE_TESTS: '#js-pipeline-tests-detail',
};

const createLegacyPipelinesDetailApp = mediator => {
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

// export default async function() {
//   createTestDetails();
//   createDagApp();
//
//   const { dataset } = document.querySelector(SELECTORS.PIPELINE_DETAILS);
//   let mediator;
//
//   if (!gon.features.graphqlPipelineHeader || !gon.features.graphqlPipelineDetails) {
//     // try {
//     //   const { default: PipelinesMediator } = await import(
//     //     /* webpackChunkName: 'PipelinesMediator' */ './pipeline_details_mediator'
//     //   );
//       mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
//       mediator.fetchPipeline();
//     // } catch {
//     //   Flash(__('An error occurred while loading the pipeline.'));
//     // }
//   }
//
//   if (gon.features.graphqlPipelineHeader) {
//     // try {
//     //   const { createPipelineHeaderApp } = await import(
//     //     /* webpackChunkName: 'createPipelineHeaderApp' */ './pipeline_details_header'
//     //   );
//       createPipelineHeaderApp(SELECTORS.PIPELINE_HEADER);
//     // } catch {
//     //   Flash(__('An error occurred while loading a section of this page.'));
//     // }
//   } else {
//     createLegacyPipelineHeaderApp(mediator);
//   }
//
//   if (gon.features.graphqlPipelineDetails) {
//     // try {
//     //   const { createPipelinesDetailApp } = await import(
//     //     /* webpackChunkName: 'createPipelinesDetailApp' */ './pipeline_details_graph'
//     //   );
//       createPipelinesDetailApp(SELECTORS.PIPELINE_GRAPH);
//     // } catch (err) {
//     //   Flash(__('An error occurred while loading the pipeline.'));
//     // }
//   } else {
//     createLegacyPipelinesDetailApp(mediator);
//   }
//
// }

export default async function() {
  createTestDetails();
  createDagApp();

  const { dataset } = document.querySelector(SELECTORS.PIPELINE_DETAILS);
  let mediator;

  let awaitMed = (!gon.features.graphqlPipelineHeader || !gon.features.graphqlPipelineDetails)
    ? import(
         /* webpackChunkName: 'PipelinesMediator' */ './pipeline_details_mediator'
       )
    : { mediator: 'hi'};

  let awaitHead = gon.features.graphqlPipelineHeader ? import(
        /* webpackChunkName: 'createPipelineHeaderApp' */ './pipeline_details_header'
      )
    : { createLegacyPipelineHeaderApp };

  let awaitGraph = gon.features.graphqlPipelineDetails ? import(
          /* webpackChunkName: 'createPipelinesDetailApp' */ './pipeline_details_graph'
        )
    : { createLegacyPipelinesDetailApp };

  const toAwait = [
   awaitMed,
   awaitHead,
   awaitGraph,
  ].filter(Boolean);

  let asyncModules;

  try {
    asyncModules = await Promise.all(toAwait);
  } catch (err) {
    console.error(err);
  }

  console.log('asyncModules', asyncModules);

  if (!gon.features.graphqlPipelineHeader || !gon.features.graphqlPipelineDetails) {
    const { default: PipelinesMediator } = asyncModules[0];
    mediator = new PipelinesMediator({ endpoint: dataset.endpoint });
    mediator.fetchPipeline();
  }

  if (gon.features.graphqlPipelineHeader) {
    const { createPipelineHeaderApp } = asyncModules[1];
    createPipelineHeaderApp(SELECTORS.PIPELINE_HEADER);
  } else {
    const { createPipelineHeaderApp } = asyncModules[1];
    createLegacyPipelineHeaderApp(mediator);
  }

  if (gon.features.graphqlPipelineDetails) {
    const { createPipelinesDetailApp } = asyncModules[2];
    createPipelinesDetailApp(SELECTORS.PIPELINE_GRAPH);
  } else {
    const { createPipelinesDetailApp } = asyncModules[2];
    createLegacyPipelinesDetailApp(mediator);
  }
}
