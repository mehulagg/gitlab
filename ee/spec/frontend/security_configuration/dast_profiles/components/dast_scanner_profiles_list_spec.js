import { mount, shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import Component from 'ee/security_configuration/dast_profiles/components/dast_scanner_profiles_list.vue';
import ProfilesList from 'ee/security_configuration/dast_profiles/components/dast_profiles_list.vue';
import { scannerProfiles } from '../mocks/mock_data';

describe('EE - DastScannerProfileList', () => {
  let wrapper;

  const defaultProps = {
    profiles: [],
    tableLabel: 'Scanner profiles',
    fields: ['profileName'],
    profilesPerPage: 10,
    errorMessage: '',
    errorDetails: [],
    fullPath: '/namespace/project',
    hasMoreProfilesToLoad: false,
    isLoading: false,
  };

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      Component,
      merge(
        {
          propsData: defaultProps,
        },
        options,
      ),
    );
  };
  const createComponent = wrapperFactory();
  const createFullComponent = wrapperFactory(mount);

  const findProfileList = () => wrapper.find(ProfilesList);

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders profile list properly', () => {
    createComponent({
      propsData: { profiles: scannerProfiles },
    });

    expect(findProfileList()).toExist();
  });

  it('passes down the props properly', () => {
    createFullComponent();

    expect(findProfileList().props()).toEqual(defaultProps);
  });

  it('sets listeners on profile list component', () => {
    const inputHandler = jest.fn();
    createComponent({
      listeners: {
        input: inputHandler,
      },
    });
    findProfileList().vm.$emit('input');

    expect(inputHandler).toHaveBeenCalled();
  });
});
