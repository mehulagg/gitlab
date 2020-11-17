import { GlDropdown, GlTabs } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import DastProfiles from 'ee/security_configuration/dast_profiles/components/dast_profiles.vue';
import setWindowLocation from 'helpers/set_window_location_helper';

const TEST_NEW_DAST_SCANNER_PROFILE_PATH = '/-/on_demand_scans/scanner_profiles/new';
const TEST_NEW_DAST_SITE_PROFILE_PATH = '/-/on_demand_scans/site_profiles/new';
const TEST_PROJECT_FULL_PATH = '/namespace/project';

describe('EE - DastProfiles', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = {
      createNewProfilePaths: {
        scannerProfile: TEST_NEW_DAST_SCANNER_PROFILE_PATH,
        siteProfile: TEST_NEW_DAST_SITE_PROFILE_PATH,
      },
      projectFullPath: TEST_PROJECT_FULL_PATH,
    };

    const defaultMocks = {
      $apollo: {
        queries: {
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
        },
        options,
      ),
    );
  };

  const createComponent = createComponentFactory();
  const createFullComponent = createComponentFactory(mount);

  const withinComponent = () => within(wrapper.element);
  const getProfilesComponent = profileType => wrapper.find(`[data-testid="${profileType}List"]`);
  const getDropdownComponent = () => wrapper.find(GlDropdown);
  const getSiteProfilesDropdownItem = text =>
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

      const heading = withinComponent().getByRole('heading', { name: /manage profiles/i });

      expect(heading).not.toBe(null);
    });

    it('has a "New Profile" dropdown menu', () => {
      createComponent();

      expect(getDropdownComponent().props('text')).toBe('New Profile');
    });

    it(`shows a "Site Profile" dropdown item that links to ${TEST_NEW_DAST_SITE_PROFILE_PATH}`, () => {
      createComponent();

      expect(getSiteProfilesDropdownItem('Site Profile').getAttribute('href')).toBe(
        TEST_NEW_DAST_SITE_PROFILE_PATH,
      );
    });

    it(`shows a "Scanner Profile" dropdown item that links to ${TEST_NEW_DAST_SCANNER_PROFILE_PATH}`, () => {
      expect(getSiteProfilesDropdownItem('Scanner Profile').getAttribute('href')).toBe(
        TEST_NEW_DAST_SCANNER_PROFILE_PATH,
      );
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
        ${'Site Profiles'}    | ${true}
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
      ${'Site Profiles'}    | ${0}  | ${'site-profiles'}
      ${'Scanner Profiles'} | ${1}  | ${'scanner-profiles'}
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
    ${'Site Profiles List'}    | ${'siteProfiles'}
    ${'Scanner Profiles List'} | ${'scannerProfiles'}
  `('$description', ({ profileType }) => {
    beforeEach(() => {
      createComponent();
    });

    it('passes down the correct default props', () => {
      expect(getProfilesComponent(profileType).props()).toEqual({
        errorMessage: '',
        errorDetails: [],
        hasMoreProfilesToLoad: false,
        isLoading: false,
        profilesPerPage: expect.any(Number),
        profiles: [],
        fields: expect.any(Array),
      });
    });

    it.each([true, false])('passes down the loading state when loading is "%s"', loading => {
      createComponent({ mocks: { $apollo: { queries: { [profileType]: { loading } } } } });

      expect(getProfilesComponent(profileType).props('isLoading')).toBe(loading);
    });

    it.each`
      givenData                                                                   | propName                   | expectedPropValue
      ${{ profileTypes: { [profileType]: { errorMessage: 'foo' } } }}             | ${'errorMessage'}          | ${'foo'}
      ${{ profileTypes: { [profileType]: { errorDetails: ['foo'] } } }}           | ${'errorDetails'}          | ${['foo']}
      ${{ profileTypes: { [profileType]: { pageInfo: { hasNextPage: true } } } }} | ${'hasMoreProfilesToLoad'} | ${true}
      ${{ profileTypes: { [profileType]: { profiles: [{ foo: 'bar' }] } } }}      | ${'profiles'}              | ${[{ foo: 'bar' }]}
    `('passes down $propName correctly', async ({ givenData, propName, expectedPropValue }) => {
      wrapper.setData(givenData);

      await wrapper.vm.$nextTick();

      expect(getProfilesComponent(profileType).props(propName)).toEqual(expectedPropValue);
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
});
