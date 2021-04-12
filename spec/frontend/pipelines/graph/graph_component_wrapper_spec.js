import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import getPipelineDetails from 'shared_queries/pipelines/get_pipeline_details.query.graphql';
import {
  IID_FAILURE,
  LAYER_VIEW,
  STAGE_VIEW,
  VIEW_TYPE_KEY,
} from '~/pipelines/components/graph/constants';
import PipelineGraph from '~/pipelines/components/graph/graph_component.vue';
import PipelineGraphWrapper from '~/pipelines/components/graph/graph_component_wrapper.vue';
import GraphViewSelector from '~/pipelines/components/graph/graph_view_selector.vue';
import StageColumnComponent from '~/pipelines/components/graph/stage_column_component.vue';
import * as parsingUtils from '~/pipelines/components/parsing_utils';
import { mockPipelineResponse } from './mock_data';

const defaultProvide = {
  graphqlResourceEtag: 'frog/amphibirama/etag/',
  metricsPath: '',
  pipelineProjectPath: 'frog/amphibirama',
  pipelineIid: '22',
};

describe('Pipeline graph wrapper', () => {
  Vue.use(VueApollo);
  useLocalStorageSpy();

  let wrapper;
  const getAlert = () => wrapper.find(GlAlert);
  const getLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const getGraph = () => wrapper.find(PipelineGraph);
  const getStageColumnTitle = () => wrapper.find('[data-testid="stage-column-title"]');
  const getAllStageColumnGroupsInColumn = () =>
    wrapper.find(StageColumnComponent).findAll('[data-testid="stage-column-group"]');
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
    mountFn = shallowMount,
    provide = {},
  } = {}) => {
    const requestHandlers = [[getPipelineDetails, getPipelineDetailsHandler]];

    const apolloProvider = createMockApollo(requestHandlers);
    createComponent({ apolloProvider, provide, mountFn });
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

  describe('when there is no pipeline iid available', () => {
    beforeEach(async () => {
      createComponentWithApollo({
        provide: {
          pipelineIid: '',
        },
      });
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
    });

    it('does not display the loading icon', () => {
      expect(getLoadingIcon().exists()).toBe(false);
    });

    it('displays the no iid alert', () => {
      expect(getAlert().exists()).toBe(true);
      expect(getAlert().text()).toBe(wrapper.vm.$options.errorTexts[IID_FAILURE]);
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
        expect(getViewSelector().exists()).toBe(false);
      });
    });

    describe('when feature flag is on', () => {
      let layersFn;
      beforeEach(async () => {
        layersFn = jest.spyOn(parsingUtils, 'listByLayers');
        createComponentWithApollo({
          provide: {
            glFeatures: {
              pipelineGraphLayersView: true,
            },
          },
          mountFn: mount,
        });

        jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();
      });

      it('appears when pipeline uses needs', () => {
        expect(getViewSelector().exists()).toBe(true);
      });

      it('switches between views', async () => {
        const groupsInFirstColumn =
          mockPipelineResponse.data.project.pipeline.stages.nodes[0].groups.nodes.length;
        expect(getAllStageColumnGroupsInColumn()).toHaveLength(groupsInFirstColumn);
        expect(getStageColumnTitle().text()).toBe('Build');
        await getViewSelector().vm.$emit('updateViewType', LAYER_VIEW);
        expect(getAllStageColumnGroupsInColumn()).toHaveLength(groupsInFirstColumn + 1);
        expect(getStageColumnTitle().text()).toBe('');
      });

      it('saves the view type to local storage', async () => {
        await getViewSelector().vm.$emit('updateViewType', LAYER_VIEW);
        expect(localStorage.setItem.mock.calls).toEqual([[VIEW_TYPE_KEY, LAYER_VIEW]]);
      });

      it('calls listByLayers only once no matter how many times view is switched', async () => {
        expect(layersFn).not.toHaveBeenCalled();
        await getViewSelector().vm.$emit('updateViewType', LAYER_VIEW);
        expect(layersFn).toHaveBeenCalledTimes(1);
        await getViewSelector().vm.$emit('updateViewType', STAGE_VIEW);
        await getViewSelector().vm.$emit('updateViewType', LAYER_VIEW);
        await getViewSelector().vm.$emit('updateViewType', STAGE_VIEW);
        expect(layersFn).toHaveBeenCalledTimes(1);
      });
    });

    describe('when feature flag is on and local storage is set', () => {
      beforeEach(async () => {
        localStorage.setItem(VIEW_TYPE_KEY, LAYER_VIEW);

        createComponentWithApollo({
          provide: {
            glFeatures: {
              pipelineGraphLayersView: true,
            },
          },
          mountFn: mount,
        });

        jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();
      });

      it('reads the view type from localStorage when available', () => {
        expect(wrapper.find('[data-testid="pipeline-view-selector"] code').text()).toContain(
          'needs:',
        );
      });
    });

    describe('when feature flag is on but pipeline does not use needs', () => {
      beforeEach(async () => {
        const nonNeedsResponse = { ...mockPipelineResponse };
        nonNeedsResponse.data.project.pipeline.usesNeeds = false;

        createComponentWithApollo({
          provide: {
            glFeatures: {
              pipelineGraphLayersView: true,
            },
          },
          mountFn: mount,
          getPipelineDetailsHandler: jest.fn().mockResolvedValue(nonNeedsResponse),
        });

        jest.runOnlyPendingTimers();
        await wrapper.vm.$nextTick();
      });

      it('does not appear when pipeline does not use needs', () => {
        expect(getViewSelector().exists()).toBe(false);
      });
    });
  });
});
