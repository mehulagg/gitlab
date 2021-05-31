import { GlAlert, GlButton, GlFormInputGroup } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import AvailableAgentsDropdown from 'ee/clusters_list/components/available_agents_dropdown.vue';
import InstallAgentModal from 'ee/clusters_list/components/install_agent_modal.vue';
import { I18N_INSTALL_AGENT_MODAL } from 'ee/clusters_list/constants';
import createAgentMutation from 'ee/clusters_list/graphql/mutations/create_agent.mutation.graphql';
import createAgentTokenMutation from 'ee/clusters_list/graphql/mutations/create_agent_token.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import CodeBlock from '~/vue_shared/components/code_block.vue';
import {
  createAgentResponse,
  createAgentErrorResponse,
  createAgentTokenResponse,
  createAgentTokenErrorResponse,
} from '../mocks/apollo';
import ModalStub from '../stubs';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('InstallAgentModal', () => {
  let wrapper;

  const i18n = I18N_INSTALL_AGENT_MODAL;
  const findModal = () => wrapper.findComponent(ModalStub);
  const findAgentDropdown = () => findModal().findComponent(AvailableAgentsDropdown);
  const findAlert = () => findModal().findComponent(GlAlert);
  const findActionButton = () =>
    findModal()
      .findAll(GlButton)
      .wrappers.find((button) => button.props('variant') === 'confirm');
  const findCancelButton = () =>
    findModal()
      .findAll(GlButton)
      .wrappers.find((button) => button.props('variant') === 'default');

  const createWrapper = (apolloProvider = {}) => {
    const provide = {
      projectPath: 'path/to/project',
      kasAddress: 'kas.example.com',
    };

    wrapper = shallowMount(InstallAgentModal, {
      attachTo: document.body,
      stubs: {
        GlModal: ModalStub,
      },
      localVue,
      apolloProvider,
      provide,
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('initial state', () => {
    it('renders the dropdown for available agents', () => {
      expect(findAgentDropdown().isVisible()).toBe(true);
    });

    it('renders a cancel button', () => {
      expect(findCancelButton().exists()).toBe(true);
      expect(findCancelButton().isVisible()).toBe(true);
      expect(findCancelButton().attributes('disabled')).toBeFalsy();
    });

    it('renders a disabled next button', () => {
      expect(findActionButton().exists()).toBe(true);
      expect(findActionButton().isVisible()).toBe(true);
      expect(findActionButton().text()).toBe(i18n.next);
      expect(findActionButton().attributes('disabled')).toBeTruthy();
    });
  });

  describe('an agent is selected', () => {
    beforeEach(() => {
      findAgentDropdown().vm.$emit('agentSelected');
    });

    it('enables the next button', () => {
      expect(findActionButton().exists()).toBe(true);
      expect(findActionButton().isVisible()).toBe(true);
      expect(findActionButton().attributes('disabled')).toBeFalsy();
    });
  });

  describe('registering an agent', () => {
    const createAgentHandler = jest.fn().mockResolvedValue(createAgentResponse);
    const createAgentTokenHandler = jest.fn().mockResolvedValue(createAgentTokenResponse);

    beforeEach(() => {
      const apolloProvider = createMockApollo([
        [createAgentMutation, createAgentHandler],
        [createAgentTokenMutation, createAgentTokenHandler],
      ]);

      createWrapper(apolloProvider);

      findAgentDropdown().vm.$emit('agentSelected');
      wrapper.vm.setAgentName('agent-name');
      findActionButton().vm.$emit('click');

      return waitForPromises();
    });

    it('creates an agent and token', () => {
      expect(createAgentHandler).toHaveBeenCalledWith({
        input: { name: 'agent-name', projectPath: 'path/to/project' },
      });

      expect(createAgentTokenHandler).toHaveBeenCalledWith({
        input: { clusterAgentId: 'agent-id', name: 'agent-name' },
      });
    });

    it('renders a done button', () => {
      expect(findActionButton().exists()).toBe(true);
      expect(findActionButton().isVisible()).toBe(true);
      expect(findActionButton().text()).toBe(i18n.done);
      expect(findActionButton().attributes('disabled')).toBeFalsy();
    });

    it('shows agent instructions', () => {
      const modalText = findModal().text();
      expect(modalText).toContain(i18n.basicInstallTitle);
      expect(modalText).toContain(i18n.basicInstallBody);

      const token = findModal().findComponent(GlFormInputGroup);
      expect(token.props('value')).toBe('mock-agent-token');

      const alert = findModal().findComponent(GlAlert);
      expect(alert.props('title')).toBe(i18n.tokenSingleUseWarningTitle);

      const code = findModal().findComponent(CodeBlock).props('code');
      expect(code).toContain('--agent-token=mock-agent-token');
      expect(code).toContain('--kas-address=kas.example.com');
    });

    describe('error creating agent', () => {
      const apolloProvider = createMockApollo([
        [createAgentMutation, jest.fn().mockResolvedValue(createAgentErrorResponse)],
      ]);

      beforeEach(() => {
        createWrapper(apolloProvider);

        findAgentDropdown().vm.$emit('agentSelected');
        findActionButton().vm.$emit('click');

        return waitForPromises();
      });

      it('displays the error message', () => {
        expect(findAlert().text()).toBe('could not create agent');
      });
    });

    describe('error creating token', () => {
      const apolloProvider = createMockApollo([
        [createAgentMutation, jest.fn().mockResolvedValue(createAgentResponse)],
        [createAgentTokenMutation, jest.fn().mockResolvedValue(createAgentTokenErrorResponse)],
      ]);

      beforeEach(() => {
        createWrapper(apolloProvider);

        findAgentDropdown().vm.$emit('agentSelected');
        findActionButton().vm.$emit('click');

        return waitForPromises();
      });

      it('displays the error message', () => {
        expect(findAlert().text()).toBe('could not create agent token');
      });
    });
  });
});
