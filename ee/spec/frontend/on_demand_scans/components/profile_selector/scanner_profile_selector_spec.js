import { mount, shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import ProfileSelector from 'ee/on_demand_scans/components/profile_selector/profile_selector.vue';
import OnDemandScansScannerProfileSelector from 'ee/on_demand_scans/components/profile_selector/scanner_profile_selector.vue';
import { scannerProfiles } from '../../mock_data';

const TEST_LIBRARY_PATH = '/test/scanner/profiles/library/path';
const TEST_NEW_PATH = '/test/new/scanner/profile/path';
const TEST_ATTRS = {
  'data-foo': 'bar',
};

describe('OnDemandScansScannerProfileSelector', () => {
  let wrapper;

  const wrapperFactory = (mountFn = shallowMount) => (options = {}) => {
    wrapper = mountFn(
      OnDemandScansScannerProfileSelector,
      merge(
        {
          propsData: {
            profiles: [],
          },
          attrs: TEST_ATTRS,
          provide: {
            scannerProfilesLibraryPath: TEST_LIBRARY_PATH,
            newScannerProfilePath: TEST_NEW_PATH,
          },
        },
        options,
      ),
    );
  };
  const createComponent = wrapperFactory();
  const createFullComponent = wrapperFactory(mount);

  const findProfileSelector = () => wrapper.find(ProfileSelector);

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders properly with profiles', () => {
    createFullComponent({
      propsData: { profiles: scannerProfiles, value: scannerProfiles[0].id },
    });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders properly without profiles', () => {
    createFullComponent();

    expect(wrapper.element).toMatchSnapshot();
  });

  it('sets listeners on profile selector component', () => {
    const inputHandler = jest.fn();
    createComponent({
      listeners: {
        input: inputHandler,
      },
    });
    findProfileSelector().vm.$emit('input');

    expect(inputHandler).toHaveBeenCalled();
  });

  describe('with profiles', () => {
    beforeEach(() => {
      createComponent({
        propsData: { profiles: scannerProfiles },
      });
    });

    it('renders profile selector', () => {
      const sel = findProfileSelector();

      expect(sel.props()).toEqual({
        libraryPath: TEST_LIBRARY_PATH,
        newProfilePath: TEST_NEW_PATH,
        profiles: scannerProfiles.map(x => ({ ...x, dropdownLabel: x.profileName })),
        value: null,
      });
      expect(sel.attributes()).toMatchObject(TEST_ATTRS);
    });
  });
});
