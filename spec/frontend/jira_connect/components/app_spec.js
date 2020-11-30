import { shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import JiraConnectApp from '~/jira_connect/components/app.vue';
import createStore from '~/jira_connect/store';

describe('JiraConnectApp', () => {
  let wrapper;
  let mockStore;

  const findAlert = () => wrapper.find(GlAlert);

  const createComponent = (options = {}) => {
    mockStore = createStore();

    // create a dummy parent component, allowing us to mock $root.$data and our global store
    const ParentComponent = {
      data() {
        return {
          state: mockStore.state,
        };
      },
    };

    wrapper = shallowMount(JiraConnectApp, {
      provide: {
        glFeatures: { newJiraConnectUi: true },
      },
      parentComponent: ParentComponent,
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findHeader = () => wrapper.find('h3');
  const findHeaderText = () => findHeader().text();

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
      mockStore.setErrorMessage(testErrorMessage);
    });

    it('renders GlAlert with error message', () => {
      expect(findAlert().isVisible()).toBe(true);
      expect(findAlert().html()).toContain(testErrorMessage);
    });
  });
});
