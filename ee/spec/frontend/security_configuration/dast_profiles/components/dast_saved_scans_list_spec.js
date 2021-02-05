import { mount, shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import Component from 'ee/security_configuration/dast_profiles/components/dast_saved_scans_list.vue';
import ProfilesList from 'ee/security_configuration/dast_profiles/components/dast_profiles_list.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { redirectTo } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { savedScans } from '../mocks/mock_data';

jest.mock('~/lib/utils/url_utility');
jest.mock('~/flash');

describe('EE - DastSavedScansList', () => {
  let wrapper;

  const defaultProps = {
    profiles: [],
    tableLabel: 'Saved scans',
    fields: [
      { key: 'name' },
      { key: 'dastSiteProfile.targetUrl' },
      { key: 'dastScannerProfile.scanType' },
    ],
    profilesPerPage: 10,
    errorMessage: '',
    errorDetails: [],
    fullPath: '/namespace/project',
    hasMoreProfilesToLoad: false,
    isLoading: false,
  };

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = extendedWrapper(
      mountFn(
        Component,
        merge(
          {
            propsData: defaultProps,
          },
          options,
        ),
      ),
    );
  };
  const createFullComponent = wrapperFactory(mount);

  const findProfileList = () => wrapper.find(ProfilesList);

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders profile list properly', () => {
    createFullComponent({
      propsData: { profiles: savedScans },
    });

    expect(findProfileList()).toExist();
  });

  it('passes down the props properly', () => {
    createFullComponent();

    expect(findProfileList().props()).toEqual(defaultProps);
  });

  it('sets listeners on profile list component', () => {
    const inputHandler = jest.fn();
    createFullComponent({
      listeners: {
        input: inputHandler,
      },
    });
    findProfileList().vm.$emit('input');

    expect(inputHandler).toHaveBeenCalled();
  });

  describe('run scan', () => {
    it('redirects to the running pipeline page on success', async () => {
      const pipelineUrl = '/pipeline/url';
      createFullComponent({
        propsData: { profiles: savedScans },
        mocks: {
          $apollo: {
            mutate: jest.fn().mockResolvedValue({
              dastProfileRun: {
                pipelineUrl,
                errors: [],
              },
            }),
          },
        },
      });
      wrapper.findByTestId('dast-scan-run-button').trigger('click');
      await waitForPromises();

      expect(redirectTo).toHaveBeenCalledWith(pipelineUrl);
      expect(createFlash).not.toHaveBeenCalled();
    });

    it('create a flash error on failure', async () => {
      createFullComponent({
        propsData: { profiles: savedScans },
        mocks: {
          $apollo: {
            mutate: jest.fn().mockRejectedValue(),
          },
        },
      });
      wrapper.findByTestId('dast-scan-run-button').trigger('click');
      await waitForPromises();

      expect(createFlash).toHaveBeenCalled();
      expect(redirectTo).not.toHaveBeenCalled();
    });

    it('create a flash error if the API responds with errors-as-data', async () => {
      createFullComponent({
        propsData: { profiles: savedScans },
        mocks: {
          $apollo: {
            mutate: jest.fn().mockResolvedValue({
              dastProfileRun: {
                pipelineUrl: null,
                errors: ['error-as-data'],
              },
            }),
          },
        },
      });
      wrapper.findByTestId('dast-scan-run-button').trigger('click');
      await waitForPromises();

      expect(createFlash).toHaveBeenCalled();
      expect(redirectTo).not.toHaveBeenCalled();
    });
  });
});
