import { GlAlert, GlEmptyState, GlSprintf } from '@gitlab/ui';
import AgentEmptyState from 'ee/clusters_list/components/agent_empty_state.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('AgentEmptyStateComponent', () => {
  let wrapper;

  const propsData = {
    hasConfigurations: false,
  };
  const provideData = {
    emptyStateImage: '/path/to/image',
    projectPath: 'path/to/project',
    agentDocsUrl: 'path/to/agentDocs',
    installDocsUrl: 'path/to/installDocs',
    getStartedDocsUrl: 'path/to/getStartedDocs',
    integrationDocsUrl: 'path/to/integrationDocs',
  };

  const findConfigurationsAlert = () => wrapper.findComponent(GlAlert);
  const findAgentDocsLink = () => wrapper.findByTestId('agent-docs-link');
  const findInstallDocsLink = () => wrapper.findByTestId('install-docs-link');
  const findIntegrationButton = () => wrapper.findByTestId('integration-primary-button');
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);

  beforeEach(() => {
    wrapper = shallowMountExtended(AgentEmptyState, {
      propsData,
      provide: provideData,
      stubs: { GlEmptyState, GlSprintf },
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('renders correct herf attributes for the links', () => {
    expect(findAgentDocsLink().attributes('href')).toBe('path/to/agentDocs');
    expect(findInstallDocsLink().attributes('href')).toBe('path/to/installDocs');
  });

  describe('when there are no agent configurations in repository', () => {
    it('should render notification message box', () => {
      expect(findConfigurationsAlert().exists()).toBe(true);
    });

    it('should disable integration button', () => {
      expect(findIntegrationButton().attributes('disabled')).toBe('true');
    });
  });

  describe('when there is a list of agent configurations', () => {
    beforeEach(() => {
      propsData.hasConfigurations = true;
      wrapper = shallowMountExtended(AgentEmptyState, {
        propsData,
        provide: provideData,
      });
    });
    it('should render content without notification message box', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findConfigurationsAlert().exists()).toBe(false);
      expect(findIntegrationButton().attributes('disabled')).toBeUndefined();
    });

    it('should render correct href for the integration button', () => {
      expect(findIntegrationButton().attributes('href')).toBe('path/to/integrationDocs');
    });
  });
});
