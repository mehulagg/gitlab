import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import VueApollo from 'vue-apollo';
import Agents from 'ee/clusters_list/components/agents.vue';
import AgentEmptyState from 'ee/clusters_list/components/agent_empty_state.vue';
import AgentTable from 'ee/clusters_list/components/agent_table.vue';
import getAgentsQuery from 'ee/clusters_list/graphql/queries/get_agents.query.graphql';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Agents', () => {
  let wrapper;

  const createWrapper = ({ agents }) => {
    const apolloQueryResponse = {
      data: {
        project: {
          clusterAgents: { nodes: agents },
          repository: { tree: { trees: { nodes: [] } } },
        },
      },
    };

    const apolloProvider = createMockApollo([
      [getAgentsQuery, jest.fn().mockResolvedValue(apolloQueryResponse)],
    ]);

    wrapper = shallowMount(Agents, {
      localVue,
      apolloProvider,
      propsData: {
        emptyStateImage: '/path/to/image',
        defaultBranchName: 'default',
        projectPath: 'path/to/project',
      },
    });

    return wrapper.vm.$nextTick();
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('when agents query has errored', () => {
    beforeEach(() => {
      return createWrapper({ agents: null });
    });

    it('displays an alert message', () => {
      expect(wrapper.find(GlAlert).exists()).toBe(true);
    });
  });

  describe('when agents query is loading', () => {
    beforeEach(() => {
      return createWrapper({ agents: [] }).then(() => {
        wrapper.setData({ loading: true });

        return wrapper.vm.$nextTick();
      });
    });

    it('displays a loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when there is a list of agents', () => {
    const agents = [
      {
        id: '1',
        name: 'agent-1',
      },
      {
        id: '2',
        name: 'agent-2',
      },
    ];

    beforeEach(() => {
      return createWrapper({ agents });
    });

    it('should render agent table', () => {
      expect(wrapper.find(AgentTable).exists()).toBe(true);
      expect(wrapper.find(AgentEmptyState).exists()).toBe(false);
    });
  });

  describe('when the agent list is empty', () => {
    beforeEach(() => {
      return createWrapper({ agents: [] });
    });

    it('should render empty state', () => {
      expect(wrapper.find(AgentTable).exists()).toBe(false);
      expect(wrapper.find(AgentEmptyState).exists()).toBe(true);
    });
  });
});
