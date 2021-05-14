import { GlButton } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { featureToMutationMap } from 'ee_else_ce/security_configuration/components/constants';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { humanize } from '~/lib/utils/text_utility';
import { redirectTo } from '~/lib/utils/url_utility';
import ManageViaMr from '~/vue_shared/security_configuration/components/manage_via_mr.vue';
import { buildConfigureSecurityFeatureMockFactory } from './apollo_mocks';

jest.mock('~/lib/utils/url_utility');

Vue.use(VueApollo);

describe('ManageViaMr component', () => {
  let wrapper;

  const findButton = () => wrapper.findComponent(GlButton);

  // This component supports different report types/mutations depending on
  // whether it's in a CE or EE context. This makes sure we are only testing
  // the ones available in the current test context.
  const supportedReportTypes = Object.entries(featureToMutationMap).map(
    ([featureType, { mutation, mutationId }]) => {
      return [humanize(featureType), featureType, mutation, mutationId];
    },
  );

  describe.each(supportedReportTypes)('%s', (featureName, featureType, mutation, mutationId) => {
    const buildConfigureSecurityFeatureMock = buildConfigureSecurityFeatureMockFactory(mutationId);
    const successHandler = async () => buildConfigureSecurityFeatureMock();
    const noSuccessPathHandler = async () =>
      buildConfigureSecurityFeatureMock({
        successPath: '',
      });
    const errorHandler = async () =>
      buildConfigureSecurityFeatureMock({
        errors: ['foo'],
      });
    const pendingHandler = () => new Promise(() => {});

    function createMockApolloProvider(handler) {
      const requestHandlers = [[mutation, handler]];

      return createMockApollo(requestHandlers);
    }

    function createComponent({ mockApollo, isFeatureConfigured = false } = {}) {
      wrapper = extendedWrapper(
        mount(ManageViaMr, {
          apolloProvider: mockApollo,
          provide: {
            projectPath: 'testProjectPath',
          },
          propsData: {
            feature: {
              name: featureName,
              type: featureType,
              configured: isFeatureConfigured,
            },
          },
        }),
      );
    }

    afterEach(() => {
      wrapper.destroy();
    });

    describe('when feature is configured', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider(successHandler);
        createComponent({ mockApollo, isFeatureConfigured: true });
      });

      it('it does not render a button', () => {
        expect(findButton().exists()).toBe(false);
      });
    });

    describe('when feature is not configured', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider(successHandler);
        createComponent({ mockApollo, isFeatureConfigured: false });
      });

      it('it does render a button', () => {
        expect(findButton().exists()).toBe(true);
      });
    });

    describe('given a pending response', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider(pendingHandler);
        createComponent({ mockApollo });
      });

      it('renders spinner correctly', async () => {
        const button = findButton();
        expect(button.props('loading')).toBe(false);
        await button.trigger('click');
        expect(button.props('loading')).toBe(true);
      });
    });

    describe('given a successful response', () => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider(successHandler);
        createComponent({ mockApollo });
      });

      it('should call redirect helper with correct value', async () => {
        await wrapper.trigger('click');
        await waitForPromises();
        expect(redirectTo).toHaveBeenCalledTimes(1);
        expect(redirectTo).toHaveBeenCalledWith('testSuccessPath');
        // This is done for UX reasons. If the loading prop is set to false
        // on success, then there's a period where the button is clickable
        // again. Instead, we want the button to display a loading indicator
        // for the remainder of the lifetime of the page (i.e., until the
        // browser can start painting the new page it's been redirected to).
        expect(findButton().props().loading).toBe(true);
      });
    });

    describe.each`
      handler                 | message
      ${noSuccessPathHandler} | ${`${featureName} merge request creation mutation failed`}
      ${errorHandler}         | ${'foo'}
    `('given an error response', ({ handler, message }) => {
      beforeEach(() => {
        const mockApollo = createMockApolloProvider(handler);
        createComponent({ mockApollo });
      });

      it('should catch and emit error', async () => {
        await wrapper.trigger('click');
        await waitForPromises();
        expect(wrapper.emitted('error')).toEqual([[message]]);
        expect(findButton().props('loading')).toBe(false);
      });
    });
  });
});
