import { shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import JiraConnectApp from '~/jira_connect/components/app.vue';
import { mutations } from '~/jira_connect/store';

describe('JiraConnectApp', () => {
  let wrapper;

  const findAlert = () => wrapper.find(GlAlert);
  const findHeader = () => wrapper.find('[data-testid="new-jira-connect-ui-heading"]');
  const findHeaderText = () => findHeader().text();

  const createComponent = (options = {}) => {
    wrapper = shallowMount(JiraConnectApp, {
      provide: {
        glFeatures: { newJiraConnectUi: true },
      },
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('template', () => {
    it('renders new UI', () => {
      createComponent();

      expect(findHeader().exists()).toBe(true);
      expect(findHeaderText()).toBe('Linked namespaces');
    });

    describe('newJiraConnectUi is false', () => {
      it('does not render new UI', () => {
        createComponent({
          provide: {
            glFeatures: { newJiraConnectUi: false },
          },
        });

        expect(findHeader().exists()).toBe(false);
      });
    });
  });

  describe('with error message', () => {
    const testErrorMessage = 'Test error';

    beforeEach(() => {
      createComponent();
      mutations.setErrorMessage(testErrorMessage);
    });

    it('renders GlAlert with error message', () => {
      expect(findAlert().isVisible()).toBe(true);
      expect(findAlert().html()).toContain(testErrorMessage);
    });
  });
});
