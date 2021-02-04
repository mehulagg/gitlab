import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlButton, GlModal } from '@gitlab/ui';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

import JiraConnectApp from '~/jira_connect/components/app.vue';
import createStore from '~/jira_connect/store';
import { SET_ALERT } from '~/jira_connect/store/mutation_types';

jest.mock('~/jira_connect/api');

describe('JiraConnectApp', () => {
  let wrapper;
  let store;

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findGlButton = () => wrapper.findComponent(GlButton);
  const findGlModal = () => wrapper.findComponent(GlModal);
  const findHeader = () => wrapper.findByTestId('new-jira-connect-ui-heading');
  const findHeaderText = () => findHeader().text();

  const createComponent = (options = {}) => {
    store = createStore();

    wrapper = extendedWrapper(
      shallowMount(JiraConnectApp, {
        store,
        provide: {
          glFeatures: { newJiraConnectUi: true },
        },
        ...options,
      }),
    );
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

    describe('when user is not logged in', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: { newJiraConnectUi: true },
            usersPath: '/users',
          },
        });
      });

      it('renders "Sign in" button', () => {
        expect(findGlButton().text()).toBe('Sign in to add namespaces');
        expect(findGlModal().exists()).toBe(false);
      });
    });

    describe('when user is logged in', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders "Add" button and modal', () => {
        expect(findGlButton().text()).toBe('Add namespace');
        expect(findGlModal().exists()).toBe(true);
      });
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

    it.each`
      message          | variant      | errorShouldRender
      ${'Test error'}  | ${'danger'}  | ${true}
      ${'Test notice'} | ${'info'}    | ${true}
      ${''}            | ${undefined} | ${false}
      ${undefined}     | ${undefined} | ${false}
    `(
      'renders correct alert when message is `$message` and variant is `$variant`',
      async ({ message, errorShouldRender, variant }) => {
        createComponent();

        store.commit(SET_ALERT, { message, variant });
        await wrapper.vm.$nextTick();

        const alert = findAlert();

        expect(alert.exists()).toBe(errorShouldRender);
        if (errorShouldRender) {
          expect(alert.isVisible()).toBe(errorShouldRender);
          expect(alert.html()).toContain(message);
          expect(alert.props('variant')).toBe(variant);
        }
      },
    );
  });
});
