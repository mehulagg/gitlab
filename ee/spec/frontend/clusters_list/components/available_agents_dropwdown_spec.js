import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import AvailableAgentsDropdown from 'ee/clusters_list/components/available_agents_dropdown.vue';
import { I18N_AVAILABLE_AGENTS_DROPDOWN } from 'ee/clusters_list/constants';
import agentConfigurationsQuery from 'ee/clusters_list/graphql/queries/agent_configurations.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('AvailableAgentsDropdown', () => {
  let wrapper;

  const i18n = I18N_AVAILABLE_AGENTS_DROPDOWN;
  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findDropdownItems = () => wrapper.findAllComponents(GlDropdownItem);

  const createWrapper = ({ extraProps = {}, isLoading = false }) => {
    const propsData = {
      projectPath: 'path/to/project',
      ...extraProps,
    };

    wrapper = (() => {
      if (isLoading) {
        const mocks = {
          $apollo: {
            queries: {
              agents: {
                loading: true,
              },
            },
          },
        };

        return shallowMount(AvailableAgentsDropdown, { mocks, propsData });
      }

      const agentConfigurationsResponse = {
        data: {
          project: {
            agentConfigurations: {
              nodes: [{ agentName: 'installed-agent' }, { agentName: 'configured-agent' }],
            },
            clusterAgents: {
              nodes: [{ name: 'installed-agent' }],
            },
          },
        },
      };

      const apolloProvider = createMockApollo([
        [agentConfigurationsQuery, jest.fn().mockResolvedValue(agentConfigurationsResponse)],
      ]);

      return shallowMount(AvailableAgentsDropdown, {
        localVue,
        apolloProvider,
        propsData,
      });
    })();
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('there are agents available', () => {
    const extraProps = {
      isRegistering: false,
    };

    beforeEach(() => {
      createWrapper({ extraProps });
    });

    it('prompts to select an agent', () => {
      expect(findDropdown().props('text')).toBe(i18n.selectAgent);
    });

    it('shows only agents that are not yet installed', () => {
      expect(findDropdownItems()).toHaveLength(1);
      expect(findDropdownItems().at(0).text()).toBe('configured-agent');
      expect(findDropdownItems().at(0).props('isChecked')).toBe(false);
    });

    describe('click events', () => {
      beforeEach(() => {
        findDropdownItems().at(0).vm.$emit('click');
      });

      it('emits agentSelected with the name of the clicked agent', () => {
        expect(wrapper.emitted('agentSelected')).toEqual([['configured-agent']]);
      });

      it('marks the clicked item as selected', () => {
        expect(findDropdown().props('text')).toBe('configured-agent');
        expect(findDropdownItems().at(0).props('isChecked')).toBe(true);
      });
    });
  });

  describe('registration in progress', () => {
    const extraProps = {
      isRegistering: true,
    };

    beforeEach(() => {
      createWrapper({ extraProps });
    });

    it('updates the text in the dropdown', () => {
      expect(findDropdown().props('text')).toBe(i18n.registeringAgent);
    });

    it('displays a loading icon', () => {
      expect(findDropdown().props('loading')).toBe(true);
    });
  });

  describe('agents query is loading', () => {
    const extraProps = {
      isRegistering: false,
    };

    beforeEach(() => {
      createWrapper({ extraProps, isLoading: true });
    });

    it('updates the text in the dropdown', () => {
      expect(findDropdown().props('text')).toBe(i18n.selectAgent);
    });

    it('displays a loading icon', () => {
      expect(findDropdown().props('loading')).toBe(true);
    });
  });
});
