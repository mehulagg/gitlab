import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import PipelineGraphWrapper from './components/graph/graph_component_wrapper.vue';

Vue.use(VueApollo);

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
                label: 'success',
                group: 'success',
                icon: 'status_success',
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
                label: 'success',
                group: 'success',
                icon: 'status_success',
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
                label: 'success',
                group: 'success',
                icon: 'status_success',
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
        return Date.now() + 600000;
      },
    },
  }),
});


const createPipelinesDetailApp = (selector, pipelineProjectPath, pipelineIid) => {
  // eslint-disable-next-line no-new
  new Vue({
    el: selector,
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
