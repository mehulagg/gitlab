import { GlLoadingIcon } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { createLocalVue, mount, shallowMount, createWrapper } from '@vue/test-utils';
import merge from 'lodash/merge';
import { createMockClient } from 'mock-apollo-client';
import VueApollo from 'vue-apollo';
import DastSiteValidation from 'ee/security_configuration/dast_site_profiles_form/components/dast_site_validation.vue';
import { DAST_SITE_VALIDATION_STATUS } from 'ee/security_configuration/dast_site_profiles_form/constants';
import dastSiteValidationQuery from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_validation.query.graphql';
import dastSiteValidationCreateMutation from 'ee/security_configuration/dast_site_profiles_form/graphql/dast_site_validation_create.mutation.graphql';
import * as responses from 'ee_jest/security_configuration/dast_site_profiles_form/mock_data/apollo_mock';
import waitForPromises from 'jest/helpers/wait_for_promises';
import download from '~/lib/utils/downloader';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

jest.mock('~/lib/utils/downloader');

const localVue = createLocalVue();
localVue.use(VueApollo);

const fullPath = 'group/project';
const targetUrl = 'https://example.com/';
const tokenId = '1';
const token = 'validation-token-123';

const validationMethods = ['text file', 'header'];

const defaultProps = {
  fullPath,
  targetUrl,
  tokenId,
  token,
};

const defaultRequestHandlers = {
  dastSiteValidation: jest.fn().mockResolvedValue(responses.dastSiteValidation()),
  dastSiteValidationCreate: jest.fn().mockResolvedValue(responses.dastSiteValidationCreate()),
};

describe('DastSiteValidation', () => {
  let wrapper;
  let apolloProvider;
  let requestHandlers;

  const mockClientFactory = handlers => {
    const mockClient = createMockClient();

    requestHandlers = {
      ...defaultRequestHandlers,
      ...handlers,
    };

    mockClient.setRequestHandler(dastSiteValidationQuery, requestHandlers.dastSiteValidation);

    mockClient.setRequestHandler(
      dastSiteValidationCreateMutation,
      requestHandlers.dastSiteValidationCreate,
    );

    return mockClient;
  };

  const respondWith = handlers => {
    apolloProvider.defaultClient = mockClientFactory(handlers);
  };

  const componentFactory = (mountFn = shallowMount) => options => {
    apolloProvider = new VueApollo({
      defaultClient: mockClientFactory(),
    });

    wrapper = mountFn(
      DastSiteValidation,
      merge(
        {},
        {
          propsData: defaultProps,
          provide: {
            glFeatures: { securityOnDemandScansHttpHeaderValidation: true },
          },
        },
        options,
        {
          localVue,
          apolloProvider,
        },
      ),
    );
  };
  const createComponent = componentFactory();
  const createFullComponent = componentFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const findByTestId = id => wrapper.find(`[data-testid="${id}"`);
  const findDownloadButton = () => findByTestId('download-dast-text-file-validation-button');
  const findValidationPathPrefix = () => findByTestId('dast-site-validation-path-prefix');
  const findValidationPathInput = () => findByTestId('dast-site-validation-path-input');
  const findValidateButton = () => findByTestId('validate-dast-site-button');
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findErrorMessage = () =>
    withinComponent().queryByText(
      /validation failed, please make sure that you follow the steps above with the chosen method./i,
    );
  const findRadioInputForValidationMethod = validationMethod =>
    withinComponent().queryByRole('radio', {
      name: new RegExp(`${validationMethod} validation`, 'i'),
    });
  const enableValidationMethod = validationMethod =>
    createWrapper(findRadioInputForValidationMethod(validationMethod)).trigger('click');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('rendering', () => {
    beforeEach(() => {
      createFullComponent();
    });

    it('renders a download button containing the token', () => {
      const downloadButton = withinComponent().getByRole('button', {
        name: 'Download validation text file',
      });
      expect(downloadButton).not.toBeNull();
    });

    it.each(validationMethods)('renders a radio input for "%s" validation', validationMethod => {
      expect(findRadioInputForValidationMethod(validationMethod)).not.toBe(null);
    });

    it('renders an input group with the target URL prepended', () => {
      const inputGroup = withinComponent().getByRole('group', {
        name: 'Step 3 - Confirm text file location and validate',
      });
      expect(inputGroup).not.toBeNull();
      expect(inputGroup.textContent).toContain(targetUrl);
    });
  });

  describe('validation methods', () => {
    describe.each(validationMethods)('common behaviour', validationMethod => {
      const expectedFileName = `GitLab-DAST-Site-Validation-${token}.txt`;

      describe.each`
        targetUrl                               | expectedPrefix                 | expectedPath        | expectedTextFilePath
        ${'https://example.com'}                | ${'https://example.com/'}      | ${''}               | ${`${expectedFileName}`}
        ${'https://example.com/'}               | ${'https://example.com/'}      | ${''}               | ${`${expectedFileName}`}
        ${'https://example.com/foo/bar'}        | ${'https://example.com/'}      | ${'foo/bar'}        | ${`foo/${expectedFileName}`}
        ${'https://example.com/foo/bar/'}       | ${'https://example.com/'}      | ${'foo/bar/'}       | ${`foo/bar/${expectedFileName}`}
        ${'https://sub.example.com/foo/bar'}    | ${'https://sub.example.com/'}  | ${'foo/bar'}        | ${`foo/${expectedFileName}`}
        ${'https://example.com/foo/index.html'} | ${'https://example.com/'}      | ${'foo/index.html'} | ${`foo/${expectedFileName}`}
        ${'https://example.com/foo/?bar="baz"'} | ${'https://example.com/'}      | ${'foo/'}           | ${`foo/${expectedFileName}`}
        ${'https://example.com:3000'}           | ${'https://example.com:3000/'} | ${''}               | ${`${expectedFileName}`}
        ${''}                                   | ${''}                          | ${''}               | ${`${expectedFileName}`}
      `(
        `validation path input when validationMethod is "${validationMethod}" and target URL is "$targetUrl"`,
        ({ targetUrl: url, expectedPrefix, expectedPath, expectedTextFilePath }) => {
          beforeEach(async () => {
            createFullComponent({
              propsData: {
                targetUrl: url,
              },
            });

            await wrapper.vm.$nextTick();

            enableValidationMethod(validationMethod);
          });

          const expectedValue =
            validationMethod === 'text file' ? expectedTextFilePath : expectedPath;

          it(`prefix is set to "${expectedPrefix}"`, () => {
            expect(findValidationPathPrefix().text()).toBe(expectedPrefix);
          });

          it(`input value defaults to "${expectedValue}"`, () => {
            expect(findValidationPathInput().element.value).toBe(expectedValue);
          });
        },
      );

      it("input value isn't automatically updated if it has been changed manually", async () => {
        createFullComponent();
        const customValidationPath = 'custom/validation/path.txt';
        findValidationPathInput().setValue(customValidationPath);
        await wrapper.setProps({
          token: 'a-completely-new-token',
        });

        expect(findValidationPathInput().element.value).toBe(customValidationPath);
      });
    });

    describe('text file validation', () => {
      it('clicking on the download button triggers a download of a text file containing the token', () => {
        createComponent();
        findDownloadButton().vm.$emit('click');

        expect(download).toHaveBeenCalledWith({
          fileName: `GitLab-DAST-Site-Validation-${token}.txt`,
          fileData: btoa(token),
        });
      });
    });

    describe('header validation', () => {
      beforeEach(async () => {
        createFullComponent();

        await wrapper.vm.$nextTick();

        enableValidationMethod('header');
      });

      it.each([
        /step 2 - add following http header to your site/i,
        /step 3 - confirm header location and validate/i,
      ])('shows the correct descriptions', descriptionText => {
        expect(withinComponent().getByText(descriptionText)).not.toBe(null);
      });

      it('shows a code block containing the http-header key with the given token', () => {
        expect(
          withinComponent().getByText(`Gitlab-On-Demand-DAST: ${token}`, {
            selector: 'code',
          }),
        ).not.toBe(null);
      });

      it('shows a button that copies the http-header to the clipboard', () => {
        const clipboardButton = wrapper.find(ClipboardButton);

        expect(clipboardButton.exists()).toBe(true);
        expect(clipboardButton.props()).toMatchObject({
          text: `Gitlab-On-Demand-DAST: ${token}`,
          title: 'Copy HTTP header to clipboard',
        });
      });
    });
  });

  describe('with the "securityOnDemandScansHttpHeaderValidation" feature flag disabled', () => {
    beforeEach(() => {
      createFullComponent({
        provide: {
          glFeatures: {
            securityOnDemandScansHttpHeaderValidation: false,
          },
        },
      });
    });

    it('does not render the http-header validation method', () => {
      expect(findRadioInputForValidationMethod('header')).toBe(null);
    });
  });

  describe.each(validationMethods)('"%s" validation submission', validationMethod => {
    beforeEach(() => {
      createFullComponent();
    });

    describe('passed', () => {
      beforeEach(() => {
        enableValidationMethod(validationMethod);
      });

      it('while validating, shows a loading state', async () => {
        findValidateButton().trigger('click');

        await wrapper.vm.$nextTick();

        expect(findLoadingIcon().exists()).toBe(true);
        expect(wrapper.text()).toContain('Validating...');
      });

      it('triggers the dastSiteValidationCreate GraphQL mutation', () => {
        findValidateButton().trigger('click');

        expect(requestHandlers.dastSiteValidationCreate).toHaveBeenCalledWith({
          projectFullPath: fullPath,
          dastSiteTokenId: tokenId,
          validationPath: wrapper.vm.validationPath,
          validationStrategy: wrapper.vm.validationMethod,
        });
      });

      it('on success, emits success event', async () => {
        respondWith({
          dastSiteValidation: jest
            .fn()
            .mockResolvedValue(responses.dastSiteValidation('PASSED_VALIDATION')),
        });

        findValidateButton().trigger('click');

        await waitForPromises();

        expect(wrapper.emitted('success')).toHaveLength(1);
      });
    });

    describe('failed', () => {
      beforeEach(() => {
        respondWith({
          dastSiteValidation: () =>
            Promise.resolve(responses.dastSiteValidation(DAST_SITE_VALIDATION_STATUS.FAILED)),
        });
      });

      it('shows failure message', async () => {
        expect(findErrorMessage()).toBe(null);

        findValidateButton().vm.$emit('click');
        await waitForPromises();

        expect(findErrorMessage()).not.toBe(null);
      });
    });

    describe.each`
      errorKind            | errorResponse
      ${'top level error'} | ${() => Promise.reject(new Error('GraphQL Network Error'))}
      ${'errors as data'}  | ${() => Promise.resolve(responses.dastSiteValidationCreate(['error#1', 'error#2']))}
    `('$errorKind', ({ errorResponse }) => {
      beforeEach(() => {
        respondWith({
          dastSiteValidationCreate: errorResponse,
        });
      });

      it('on error, shows error state', async () => {
        expect(findErrorMessage()).toBe(null);

        findValidateButton().vm.$emit('click');

        await waitForPromises();

        expect(findErrorMessage()).not.toBe(null);
      });
    });
  });
});
