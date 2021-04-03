import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import getPipelineDetails from 'shared_queries/pipelines/get_pipeline_details.query.graphql';
import { DOWNSTREAM, GRAPHQL, UPSTREAM } from '~/pipelines/components/graph/constants';
import PipelineGraph from '~/pipelines/components/graph/graph_component.vue';
import LinkedPipeline from '~/pipelines/components/graph/linked_pipeline.vue';
import LinkedPipelinesColumn from '~/pipelines/components/graph/linked_pipelines_column.vue';
import { LOAD_FAILURE } from '~/pipelines/constants';
import {
  mockPipelineResponse,
  pipelineWithUpstreamDownstream,
  wrappedPipelineReturn,
} from './mock_data';

const processedPipeline = pipelineWithUpstreamDownstream(mockPipelineResponse);

describe('Linked Pipelines Column', () => {
  const defaultProps = {
    columnTitle: 'Downstream',
    linkedPipelines: processedPipeline.downstream,
    type: DOWNSTREAM,
    configPaths: {
      metricsPath: '',
      graphqlResourceEtag: 'this/is/a/path',
    },
  };

  let wrapper;
  const findLinkedColumnTitle = () => wrapper.find('[data-testid="linked-column-title"]');
  const findLinkedPipelineElements = () => wrapper.findAll(LinkedPipeline);
  const findPipelineGraph = () => wrapper.find(PipelineGraph);
  const findExpandButton = () => wrapper.find('[data-testid="expand-pipeline-button"]');

  const localVue = createLocalVue();
  localVue.use(VueApollo);

  const createComponent = ({ apolloProvider, mountFn = shallowMount, props = {} } = {}) => {
    wrapper = mountFn(LinkedPipelinesColumn, {
      apolloProvider,
      localVue,
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        dataMethod: GRAPHQL,
      },
    });
  };

  const createComponentWithApollo = ({
    mountFn = shallowMount,
    getPipelineDetailsHandler = jest.fn().mockResolvedValue(wrappedPipelineReturn),
    props = {},
  } = {}) => {
    const requestHandlers = [[getPipelineDetails, getPipelineDetailsHandler]];

    const apolloProvider = createMockApollo(requestHandlers);
    createComponent({ apolloProvider, mountFn, props });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('it renders correctly', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the pipeline title', () => {
      expect(findLinkedColumnTitle().text()).toBe(defaultProps.columnTitle);
    });

    it('renders the correct number of linked pipelines', () => {
      expect(findLinkedPipelineElements()).toHaveLength(defaultProps.linkedPipelines.length);
    });
  });

  describe('click action', () => {
    const clickExpandButton = async () => {
      await findExpandButton().trigger('click');
      await wrapper.vm.$nextTick();
    };

    const clickExpandButtonAndAwaitTimers = async () => {
      await clickExpandButton();
      jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();
    };

    describe('downstream', () => {
      describe('when successful', () => {
        beforeEach(() => {
          createComponentWithApollo({ mountFn: mount });
        });

        it('toggles the pipeline visibility', async () => {
          expect(findPipelineGraph().exists()).toBe(false);
          await clickExpandButtonAndAwaitTimers();
          expect(findPipelineGraph().exists()).toBe(true);
          await clickExpandButton();
          expect(findPipelineGraph().exists()).toBe(false);
        });
      });

      describe('on error', () => {
        beforeEach(() => {
          createComponentWithApollo({
            mountFn: mount,
            getPipelineDetailsHandler: jest.fn().mockRejectedValue(new Error('GraphQL error')),
          });
        });

        it('emits the error', async () => {
          await clickExpandButton();
          expect(wrapper.emitted().error).toEqual([[{ type: LOAD_FAILURE, skipSentry: true }]]);
        });

        it('does not show the pipeline', async () => {
          expect(findPipelineGraph().exists()).toBe(false);
          await clickExpandButtonAndAwaitTimers();
          expect(findPipelineGraph().exists()).toBe(false);
        });
      });
    });

    describe('upstream', () => {
      const upstreamProps = {
        columnTitle: 'Upstream',
        /*
          Because the IDs need to match to work, rather
          than make new mock data, we are representing
          the upstream pipeline with the downstream data.
        */
        linkedPipelines: processedPipeline.downstream,
        type: UPSTREAM,
      };

      describe('when successful', () => {
        beforeEach(() => {
          createComponentWithApollo({
            mountFn: mount,
            props: upstreamProps,
          });
        });

        it('toggles the pipeline visibility', async () => {
          expect(findPipelineGraph().exists()).toBe(false);
          await clickExpandButtonAndAwaitTimers();
          expect(findPipelineGraph().exists()).toBe(true);
          await clickExpandButton();
          expect(findPipelineGraph().exists()).toBe(false);
        });
      });

      describe('on error', () => {
        beforeEach(() => {
          createComponentWithApollo({
            mountFn: mount,
            getPipelineDetailsHandler: jest.fn().mockRejectedValue(new Error('GraphQL error')),
            props: upstreamProps,
          });
        });

        it('emits the error', async () => {
          await clickExpandButton();
          expect(wrapper.emitted().error).toEqual([[{ type: LOAD_FAILURE, skipSentry: true }]]);
        });

        it('does not show the pipeline', async () => {
          expect(findPipelineGraph().exists()).toBe(false);
          await clickExpandButtonAndAwaitTimers();
          expect(findPipelineGraph().exists()).toBe(false);
        });
      });
    });
  });
});
