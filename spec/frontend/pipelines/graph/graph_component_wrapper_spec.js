import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import getPipelineDetails from 'shared_queries/pipelines/get_pipeline_details.query.graphql';
import PipelineGraph from '~/pipelines/components/graph/graph_component.vue';
import PipelineGraphWrapper from '~/pipelines/components/graph/graph_component_wrapper.vue';
import GraphViewSelector from '~/pipelines/components/graph/graph_view_selector.vue';
import { mockPipelineResponse } from './mock_data';

const defaultProvide = {
  graphqlResourceEtag: 'frog/amphibirama/etag/',
  metricsPath: '',
  pipelineProjectPath: 'frog/amphibirama',
  pipelineIid: '22',
};

describe('Pipeline graph wrapper', () => {
  Vue.use(VueApollo);

  let wrapper;
  const getAlert = () => wrapper.find(GlAlert);
  const getLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const getGraph = () => wrapper.find(PipelineGraph);
  const getViewSelector = () => wrapper.find(GraphViewSelector);

  const createComponent = ({
    apolloProvider,
    data = {},
    provide = {},
    mountFn = shallowMount,
  } = {}) => {
    wrapper = mountFn(PipelineGraphWrapper, {
      provide: {
        ...defaultProvide,
        ...provide,
      },
      apolloProvider,
      data() {
        return {
          ...data,
        };
      },
    });
  };

  const createComponentWithApollo = ({
    getPipelineDetailsHandler = jest.fn().mockResolvedValue(mockPipelineResponse),
    provide = {},
  } = {}) => {
    const requestHandlers = [[getPipelineDetails, getPipelineDetailsHandler]];

    const apolloProvider = createMockApollo(requestHandlers);
    createComponent({ apolloProvider, provide });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when data is loading', () => {
    it('displays the loading icon', () => {
      createComponentWithApollo();
      expect(getLoadingIcon().exists()).toBe(true);
    });

    it('does not display the alert', () => {
      createComponentWithApollo();
      expect(getAlert().exists()).toBe(false);
    });

    it('does not display the graph', () => {
      createComponentWithApollo();
      expect(getGraph().exists()).toBe(false);
    });
  });

  describe('when data has loaded', () => {
    beforeEach(async () => {
      createComponentWithApollo();
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
    });

    it('does not display the loading icon', () => {
      expect(getLoadingIcon().exists()).toBe(false);
    });

    it('does not display the alert', () => {
      expect(getAlert().exists()).toBe(false);
    });

    it('displays the graph', () => {
      expect(getGraph().exists()).toBe(true);
    });

    it('passes the etag resource and metrics path to the graph', () => {
      expect(getGraph().props('configPaths')).toMatchObject({
        graphqlResourceEtag: defaultProvide.graphqlResourceEtag,
        metricsPath: defaultProvide.metricsPath,
      });
    });
  });

  describe('when there is an error', () => {
    beforeEach(async () => {
      createComponentWithApollo({
        getPipelineDetailsHandler: jest.fn().mockRejectedValue(new Error('GraphQL error')),
      });
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
    });

    it('does not display the loading icon', () => {
      expect(getLoadingIcon().exists()).toBe(false);
    });

    it('displays the alert', () => {
      expect(getAlert().exists()).toBe(true);
    });

    it('does not display the graph', () => {
      expect(getGraph().exists()).toBe(false);
    });
  });

  describe('when refresh action is emitted', () => {
    beforeEach(async () => {
      createComponentWithApollo();
      jest.spyOn(wrapper.vm.$apollo.queries.pipeline, 'refetch');
      await wrapper.vm.$nextTick();
      getGraph().vm.$emit('refreshPipelineGraph');
    });

    it('calls refetch', () => {
      expect(wrapper.vm.$apollo.queries.pipeline.refetch).toHaveBeenCalled();
    });
  });

  describe('when query times out', () => {
    const advanceApolloTimers = async () => {
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
      await wrapper.vm.$nextTick();
    };

    beforeEach(async () => {
      const errorData = {
        data: {
          project: {
            pipelines: null,
          },
        },
        errors: [{ message: 'timeout' }],
      };

      const failSucceedFail = jest
        .fn()
        .mockResolvedValueOnce(errorData)
        .mockResolvedValueOnce(mockPipelineResponse)
        .mockResolvedValueOnce(errorData);

      createComponentWithApollo({ getPipelineDetailsHandler: failSucceedFail });
      await wrapper.vm.$nextTick();
    });

    it('shows correct errors and does not overwrite populated data when data is empty', async () => {
      /* fails at first, shows error, no data yet */
      expect(getAlert().exists()).toBe(true);
      expect(getGraph().exists()).toBe(false);

      /* succeeds, clears error, shows graph */
      await advanceApolloTimers();
      expect(getAlert().exists()).toBe(false);
      expect(getGraph().exists()).toBe(true);

      /* fails again, alert returns but data persists */
      await advanceApolloTimers();
      expect(getAlert().exists()).toBe(true);
      expect(getGraph().exists()).toBe(true);
    });
  });

  describe('view dropdown', () => {
    describe('when feature flag is off', () => {
      beforeEach(async () => {
        createComponentWithApollo();
        jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();
      });

      it('does not appear', () => {
        console.log('1', wrapper.html());
        expect(getViewSelector().exists()).toBe(false);
      });
    });

    describe('when feature flag is on', () => {
      beforeEach(async () => {
        createComponentWithApollo({
          provide: {
            glFeatures: {
              pipelineGraphLayersView: true,
            },
          },
        });

        jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();
      });

      it('appears', () => {
        console.log(wrapper.html());
        expect(getViewSelector().exists()).toBe(true);
      });
    });
  });
});
