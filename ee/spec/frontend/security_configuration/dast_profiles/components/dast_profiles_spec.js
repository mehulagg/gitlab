import { GlDropdown, GlTabs } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import DastProfiles from 'ee/security_configuration/dast_profiles/components/dast_profiles.vue';
import setWindowLocation from 'helpers/set_window_location_helper';

const TEST_NEW_DAST_SAVED_SCAN_PATH = '/-/on_demand_scans/new';
const TEST_NEW_DAST_SCANNER_PROFILE_PATH = '/-/on_demand_scans/scanner_profiles/new';
const TEST_NEW_DAST_SITE_PROFILE_PATH = '/-/on_demand_scans/site_profiles/new';
const TEST_PROJECT_FULL_PATH = '/namespace/project';

describe('EE - DastProfiles', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = {
      createNewProfilePaths: {
        savedScan: TEST_NEW_DAST_SAVED_SCAN_PATH,
        scannerProfile: TEST_NEW_DAST_SCANNER_PROFILE_PATH,
        siteProfile: TEST_NEW_DAST_SITE_PROFILE_PATH,
      },
      projectFullPath: TEST_PROJECT_FULL_PATH,
    };

    const defaultMocks = {
      $apollo: {
        queries: {
          savedScans: {
            fetchMore: jest.fn().mockResolvedValue(),
          },
          siteProfiles: {
            fetchMore: jest.fn().mockResolvedValue(),
          },
          scannerProfiles: {
            fetchMore: jest.fn().mockResolvedValue(),
          },
        },
        mutate: jest.fn().mockResolvedValue(),
        addSmartQuery: jest.fn(),
      },
    };

    wrapper = mountFn(
      DastProfiles,
      merge(
        {},
        {
          propsData: defaultProps,
          mocks: defaultMocks,
          provide: {
            glFeatures: {
              dastSavedScans: true,
            },
          },
        },
        options,
      ),
    );
  };

  const createComponent = createComponentFactory();
  const createFullComponent = createComponentFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const getProfilesComponent = (profileType) => wrapper.find(`[data-testid="${profileType}List"]`);
  const getDropdownComponent = () => wrapper.find(GlDropdown);
  const getSiteProfilesDropdownItem = (text) =>
    within(getDropdownComponent().element).queryByText(text);
  const getTabsComponent = () => wrapper.find(GlTabs);
  const getTab = ({ tabName, selected }) =>
    withinComponent().getByRole('tab', {
      name: tabName,
      selected,
    });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('header', () => {
    it('shows a heading that describes the purpose of the page', () => {
      createFullComponent();

      const heading = withinComponent().getByRole('heading', { name: /manage dast scans/i });

      expect(heading).not.toBe(null);
    });

    it('has a "New" dropdown menu', () => {
      createComponent();

      expect(getDropdownComponent().props('text')).toBe('New');
    });

    it.each`
      itemName             | href
      ${'DAST Scan'}       | ${TEST_NEW_DAST_SAVED_SCAN_PATH}
      ${'Site Profile'}    | ${TEST_NEW_DAST_SITE_PROFILE_PATH}
      ${'Scanner Profile'} | ${TEST_NEW_DAST_SCANNER_PROFILE_PATH}
    `('shows a "$itemName" dropdown item that links to $href', ({ itemName, href }) => {
      createComponent();

      expect(getSiteProfilesDropdownItem(itemName).getAttribute('href')).toBe(href);
    });
  });

  describe('tabs', () => {
    const originalLocation = window.location;

    describe('without location hash set', () => {
      beforeEach(() => {
        createFullComponent();
      });

      it('shows a tab-list that contains the different profile categories', () => {
        const tabList = withinComponent().getByRole('tablist');

        expect(tabList).not.toBe(null);
      });

      it.each`
        tabName               | shouldBeSelectedByDefault
        ${'Saved Scans'}      | ${true}
        ${'Site Profiles'}    | ${false}
        ${'Scanner Profiles'} | ${false}
      `(
        'shows a "$tabName" tab which has "selected" set to "$shouldBeSelectedByDefault"',
        ({ tabName, shouldBeSelectedByDefault }) => {
          const tab = getTab({
            tabName,
            selected: shouldBeSelectedByDefault,
          });

          expect(tab).not.toBe(null);
        },
      );
    });

    describe.each`
      tabName               | index | givenLocationHash
      ${'Saved Scans'}      | ${0}  | ${'saved-scans'}
      ${'Site Profiles'}    | ${1}  | ${'site-profiles'}
      ${'Scanner Profiles'} | ${2}  | ${'scanner-profiles'}
    `('with location hash set to "$givenLocationHash"', ({ tabName, index, givenLocationHash }) => {
      beforeEach(() => {
        setWindowLocation(`http://foo.com/index#${givenLocationHash}`);
        createFullComponent();
      });

      afterEach(() => {
        window.location = originalLocation;
      });

      it(`has "${tabName}" selected`, () => {
        const tab = getTab({
          tabName,
          selected: true,
        });

        expect(tab).not.toBe(null);
      });

      it('updates the browsers URL to contain the selected tab', () => {
        window.location.hash = '';

        getTabsComponent().vm.$emit('input', index);

        expect(window.location.hash).toBe(givenLocationHash);
      });
    });
  });

  describe.each`
    description                | profileType
    ${'Saved Scans List'}      | ${'savedScans'}
    ${'Site Profiles List'}    | ${'siteProfiles'}
    ${'Scanner Profiles List'} | ${'scannerProfiles'}
  `('$description', ({ profileType }) => {
    beforeEach(() => {
      createComponent();
    });

    it('passes down the loading state when loading is true', () => {
      createComponent({ mocks: { $apollo: { queries: { [profileType]: { loading: true } } } } });

      expect(getProfilesComponent(profileType).attributes('is-loading')).toBe('true');
    });

    it.each`
      givenData                                                                   | propName                       | expectedPropValue
      ${{ profileTypes: { [profileType]: { errorMessage: 'foo' } } }}             | ${'error-message'}             | ${'foo'}
      ${{ profileTypes: { [profileType]: { errorDetails: ['foo'] } } }}           | ${'error-details'}             | ${'foo'}
      ${{ profileTypes: { [profileType]: { pageInfo: { hasNextPage: true } } } }} | ${'has-more-profiles-to-load'} | ${'true'}
    `('passes down $propName correctly', async ({ givenData, propName, expectedPropValue }) => {
      wrapper.setData(givenData);

      await wrapper.vm.$nextTick();

      expect(getProfilesComponent(profileType).attributes(propName)).toEqual(expectedPropValue);
    });

    it('fetches more results when "@load-more-profiles" is emitted', () => {
      const {
        $apollo: {
          queries: {
            [profileType]: { fetchMore },
          },
        },
      } = wrapper.vm;

      expect(fetchMore).not.toHaveBeenCalled();

      getProfilesComponent(profileType).vm.$emit('load-more-profiles');

      expect(fetchMore).toHaveBeenCalledTimes(1);
    });

    it('deletes profile when "@delete-profile" is emitted', () => {
      const {
        $apollo: { mutate },
      } = wrapper.vm;

      expect(mutate).not.toHaveBeenCalled();

      getProfilesComponent(profileType).vm.$emit('delete-profile');

      expect(mutate).toHaveBeenCalledTimes(1);
    });
  });

  describe('dastSavedScans feature flag disabled', () => {
    beforeEach(() => {
      createFullComponent({
        provide: {
          glFeatures: {
            dastSavedScans: false,
          },
        },
      });
    });

    it('does not show a "DAST Scan" item in the dropdown', () => {
      expect(getSiteProfilesDropdownItem('DAST Scan')).toBe(null);
    });

    it('shows only 2 tabs', () => {
      expect(withinComponent().getAllByRole('tab')).toHaveLength(2);
    });

    it('"Site Profile" tab should be selected by default', () => {
      const tab = getTab({
        tabName: 'Site Profiles',
        selected: true,
      });

      expect(tab).not.toBe(null);
    });
  });
});
