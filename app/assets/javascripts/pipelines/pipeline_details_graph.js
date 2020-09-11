import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import PipelineGraphWrapper from './components/graph/graph_component_wrapper.vue';

Vue.use(VueApollo);

const mockStatus = {
  icon: 'status_canceled', // used in ci-icon via job and jobDropdown (group)
  tooltip: 'status_tooltip', // used in job %{remainingTime}
  has_details: true, // used in job
  details_path: '/example/example-project/-/jobs/7', // used in job
  group: 'canceled', // used in ci-icon via job and jobDropdown (group)
  label: 'status_label', // used in group for jobDropdown (group)
  text: '', // may or may not be used
  action: {
    button_title: 'Retry this job',
    icon: 'retry', // used
    method: 'post', // may or may not be used
    path: '/example/example-project/-/jobs/id/retry', // used
    title: 'Retry', // used
  }
}

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient({
    Pipeline: {
      upstream() {
        return {
          nodes: [
            {
              id: 1378,
              path: 'example/example/-/pipelines/1378',
              project: {
                id: 52,
                name: 'eltern-pipe',
              },
              status: {
                label: 'running',
                icon: 'status_running',
              },
              sourceJob: {
                name: 'pete',
              }
            },
          ]
        }
      },
      downstream() {
        return {
          nodes: [
            {
              id: 1398,
              path: 'example/example/-/pipelines/1398',
              project: {
                id: 32,
                name: 'kinder-pipe',
              },
              status :{
                label: 'running',
                icon: 'status_running',
              },
              sourceJob: {
                name: 'build_b',
              }
            },
            {
              id: 1399,
              path: 'example/example/-/pipelines/1399',
              project: {
                id: 39,
                name: 'wee-pipe',
              },
              status :{
                label: 'running',
                icon: 'status_running',
              },
              sourceJob: {
                name: 'test_a',
              }
            },
          ]
        }
      }
    },
    CiJob: {
      scheduled() {
        return false;
      },
      scheduledAt() {
        // let d = new Date();
        // d.setMinutes(d.getMinutes() + 5);
        // return d;
        return Date.now() + 600000;
      },
      status() {
        return mockStatus;
      }
    },
    CiGroup: {
      status() {
        return {
          label: 'cool stage bro',
          ...mockStatus
        };
      }
    },
    CiStage: {
      status() {
        return {
          action: {
            icon: 'play',
            title: 'play this song for me',
            path: 'play/example/id',
          }
        }
      }
    },
  }),
});


const createPipelinesDetailApp = (pipelineProjectPath, pipelineIid) => {
  // eslint-disable-next-line no-new
  new Vue({
    el: '#js-pipeline-graph-vue',
    components: {
      PipelineGraphWrapper,
    },
    apolloProvider,
    provide: {
      pipelineProjectPath,
      pipelineIid,
    },
    render(createElement) {
      return createElement('pipeline-graph-wrapper')
    }
  });
};

export default createPipelinesDetailApp;
