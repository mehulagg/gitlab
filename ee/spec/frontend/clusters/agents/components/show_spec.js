import { GlAlert, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import ClusterAgentShow from 'ee/clusters/agents/components/show.vue';
import TokenTable from 'ee/clusters/agents/components/token_table.vue';
import getAgentQuery from 'ee/clusters/agents/graphql/queries/get_cluster_agent.query.graphql';
import { useFakeDate } from 'helpers/fake_date';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('ClusterAgentShow', () => {
  let wrapper;
  useFakeDate([2021, 2, 15]);

  const propsData = {
    agentName: 'cluster-agent',
    projectPath: 'path/to/project',
  };

  const defaultClusterAgent = {
    id: '1',
    createdAt: '2021-02-13T00:00:00Z',
    createdByUser: {
      name: 'user-1',
    },
    tokens: {
      count: 1,
      nodes: [],
    },
  };

  const createWrapper = ({ clusterAgent, queryResponse = null }) => {
    const agentQueryResponse =
      queryResponse || jest.fn().mockResolvedValue({ data: { project: { clusterAgent } } });
    const apolloProvider = createMockApollo([[getAgentQuery, agentQueryResponse]]);

    wrapper = shallowMount(ClusterAgentShow, {
      localVue,
      apolloProvider,
      propsData,
      stubs: { GlSprintf, TimeAgoTooltip },
    });
  };

  const findCreatedText = () => wrapper.find('[data-testid="cluster-agent-create-info"]').text();
  const findTokenCount = () => wrapper.find('[data-testid="cluster-agent-token-count"]').text();

  beforeEach(() => {
    return createWrapper({ clusterAgent: defaultClusterAgent });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('displays the agent name', () => {
    expect(wrapper.text()).toContain(propsData.agentName);
  });

  it('displays agent create information', () => {
    expect(findCreatedText()).toMatchInterpolatedText('Created by user-1 2 days ago');
  });

  describe('when create user is unknown', () => {
    const missingUser = {
      ...defaultClusterAgent,
      createdByUser: null,
    };

    beforeEach(() => {
      return createWrapper({ clusterAgent: missingUser });
    });

    it('displays agent create information with unknown user', () => {
      expect(findCreatedText()).toMatchInterpolatedText('Created by Unknown user 2 days ago');
    });
  });

  it('displays token count', () => {
    expect(findTokenCount()).toMatchInterpolatedText(
      `${ClusterAgentShow.i18n.tokens} ${defaultClusterAgent.tokens.count}`,
    );
  });

  describe('when token count is missing', () => {
    const missingTokens = {
      ...defaultClusterAgent,
      tokens: null,
    };

    beforeEach(() => {
      return createWrapper({ clusterAgent: missingTokens });
    });

    it('displays token header with no count', () => {
      expect(findTokenCount()).toMatchInterpolatedText(`${ClusterAgentShow.i18n.tokens}`);
    });
  });

  it('renders token table', () => {
    expect(wrapper.find(TokenTable).exists()).toBe(true);
  });

  describe('when the agent query is loading', () => {
    beforeEach(() => {
      return createWrapper({
        clusterAgent: null,
        queryResponse: jest.fn().mockReturnValue(new Promise(() => {})),
      });
    });

    it('displays a loading icon', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when the agent query has errored', () => {
    beforeEach(() => {
      createWrapper({ clusterAgent: null, queryResponse: jest.fn().mockRejectedValue() });
      return waitForPromises();
    });

    it('displays an alert message', () => {
      expect(wrapper.find(GlAlert).exists()).toBe(true);
      expect(wrapper.text()).toContain(ClusterAgentShow.i18n.loadingError);
    });
  });
});
