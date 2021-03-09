import { GlAlert } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import DastFailedSiteValidations from 'ee/security_configuration/dast_profiles/components/dast_failed_site_validations.vue';
import dastFailedSiteValidationsQuery from 'ee/security_configuration/dast_profiles/graphql/dast_failed_site_validations.query.graphql';
import dastSiteValidationRevokeMutation from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validation_revoke.mutation.graphql';
import createApolloProvider from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { dastSiteValidationRevoke as dastSiteValidationRevokeResponse } from '../../dast_site_validation/mock_data/apollo_mock';
import { dastSiteValidations as dastSiteValidationsResponse } from '../mocks/apollo_mock';
import { failedSiteValidations } from '../mocks/mock_data';

const TEST_PROJECT_FULL_PATH = '/namespace/project';
const GlModal = {
  template: '<div data-testid="validation-modal" />',
  methods: {
    show: () => {},
  },
};

const localVue = createLocalVue();

describe('EE - DastFailedSiteValidations', () => {
  let wrapper;
  let requestHandlers;

  const createMockApolloProvider = (handlers) => {
    localVue.use(VueApollo);
    requestHandlers = handlers;
    return createApolloProvider([
      [dastFailedSiteValidationsQuery, requestHandlers.dastFailedSiteValidations],
      [dastSiteValidationRevokeMutation, requestHandlers.dastSiteValidationRevoke],
    ]);
  };

  const createComponentFactory = (mountFn = shallowMount) => (options = {}, handlers) => {
    const defaultProps = {
      fullPath: TEST_PROJECT_FULL_PATH,
    };

    wrapper = extendedWrapper(
      mountFn(
        DastFailedSiteValidations,
        merge(
          {
            propsData: defaultProps,
            localVue,
            apolloProvider: createMockApolloProvider(handlers),
            stubs: {
              GlModal,
            },
          },
          options,
        ),
      ),
    );
  };

  const createFullComponent = createComponentFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const findFirstRetryButton = () =>
    withinComponent().getAllByRole('button', { name: /retry validation/i })[0];
  const findFirstDismissButton = () =>
    withinComponent().getAllByRole('button', { name: /dismiss/i })[0];
  const findValidationModal = () => wrapper.findByTestId('validation-modal');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with failed site validations', () => {
    beforeEach(() => {
      createFullComponent(
        {},
        {
          dastFailedSiteValidations: jest
            .fn()
            .mockResolvedValue(dastSiteValidationsResponse(failedSiteValidations)),
          dastSiteValidationRevoke: jest.fn().mockResolvedValue(dastSiteValidationRevokeResponse()),
        },
      );
    });

    it('triggers the dastSiteValidations query', () => {
      expect(requestHandlers.dastFailedSiteValidations).toHaveBeenCalledWith({
        fullPath: TEST_PROJECT_FULL_PATH,
      });
    });

    it('renders an alert for each failed validation', () => {
      expect(wrapper.findAllComponents(GlAlert)).toHaveLength(failedSiteValidations.length);
    });

    it.each`
      index | expectedUrl
      ${0}  | ${'http://example.com/'}
      ${1}  | ${'https://example.com/'}
    `('shows parsed URL $expectedUrl in alert #$index', ({ index, expectedUrl }) => {
      expect(wrapper.findAllComponents(GlAlert).at(index).text()).toMatchInterpolatedText(
        `Validation failed for ${expectedUrl}. Retry validation.`,
      );
    });

    it('shows the validation modal when clicking on a retry button', async () => {
      expect(findValidationModal().exists()).toBe(false);

      findFirstRetryButton().click();
      await wrapper.vm.$nextTick();

      expect(findValidationModal().exists()).toBe(true);
      expect(findValidationModal().attributes('targetUrl')).toBe(failedSiteValidations[0].url);
    });

    it('triggers the dastSiteValidationRevoke GraphQL mutation', async () => {
      findFirstDismissButton().click();
      await wrapper.vm.$nextTick();

      expect(wrapper.findAllComponents(GlAlert)).toHaveLength(1);
      expect(requestHandlers.dastSiteValidationRevoke).toHaveBeenCalledWith({
        fullPath: TEST_PROJECT_FULL_PATH,
        normalizedTargetUrl: failedSiteValidations[0].normalizedTargetUrl,
      });
    });
  });
});
