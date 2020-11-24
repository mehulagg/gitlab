import { GlDropdownItem } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { merge } from 'lodash';
import OnDemandScansProfileSelector from 'ee/on_demand_scans/components/profile_selector/profile_selector.vue';
import { scannerProfiles } from '../../mock_data';

describe('OnDemandScansProfileSelector', () => {
  let wrapper;

  const defaultProps = {
    libraryPath: '/path/to/profiles/library',
    newProfilePath: '/path/to/new/profile/form',
    profiles: [],
  };

  const findByTestId = testId => wrapper.find(`[data-testid="${testId}"]`);
  const findProfilesLibraryPathLink = () => findByTestId('manage-profiles-link');
  const findProfilesDropdown = () => findByTestId('profiles-dropdown');
  const findCreateNewProfileLink = () => findByTestId('create-profile-link');
  const findSelectedProfileSummary = () => findByTestId('selected-profile-summary');
  const parseDropdownItems = () =>
    findProfilesDropdown()
      .findAll(GlDropdownItem)
      .wrappers.map(x => ({
        text: x.text(),
        isChecked: x.props('isChecked'),
      }));

  const selectFirstProfile = () => {
    return findProfilesDropdown()
      .find(GlDropdownItem)
      .vm.$emit('click');
  };

  const createFullComponent = (options = {}) => {
    wrapper = mount(
      OnDemandScansProfileSelector,
      merge(
        {
          propsData: defaultProps,
          slots: {
            title: 'Section title',
            label: 'Use existing scanner profile',
            'no-profiles': 'No profile yet',
            'new-profile': 'Create a new profile',
          },
          scopedSlots: {
            summary: "<div>{{ props.profile.profileName }}'s summary</div>",
          },
        },
        options,
      ),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows section title and link to profiles library', () => {
    createFullComponent();

    expect(wrapper.text()).toContain('Section title');
  });

  describe('when there are no profiles yet', () => {
    beforeEach(() => {
      createFullComponent();
    });

    it('disables the link to profiles library', () => {
      expect(findProfilesLibraryPathLink().props('disabled')).toBe(true);
    });

    it('shows a help text and a link to create a new profile', () => {
      const link = findCreateNewProfileLink();

      expect(wrapper.text()).toContain('No profile yet');
      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe('/path/to/new/profile/form');
      expect(link.text()).toBe('Create a new profile');
    });
  });

  describe('when there are profiles', () => {
    beforeEach(() => {
      createFullComponent({
        propsData: { profiles: scannerProfiles },
      });
    });

    it('enables link to profiles management', () => {
      expect(findProfilesLibraryPathLink().props('disabled')).toBe(false);
      expect(findProfilesLibraryPathLink().attributes('href')).toBe('/path/to/profiles/library');
    });

    it('shows a dropdown containing the profiles', () => {
      const dropdown = findProfilesDropdown();

      expect(wrapper.text()).toContain('Use existing scanner profile');
      expect(dropdown.exists()).toBe(true);
      expect(dropdown.element.children).toHaveLength(scannerProfiles.length);
    });

    it('when a profile is selected, input event is emitted', async () => {
      await selectFirstProfile();

      expect(wrapper.emitted('input')).toEqual([[scannerProfiles[0].id]]);
    });

    it('shows dropdown items for each profile', () => {
      expect(parseDropdownItems()).toEqual(
        scannerProfiles.map(x => ({
          text: x.profileName,
          isChecked: false,
        })),
      );
    });

    it('does not show summary', () => {
      expect(findSelectedProfileSummary().exists()).toBe(false);
    });
  });

  describe('when profile is selected', () => {
    let selectedProfile;

    beforeEach(() => {
      [selectedProfile] = scannerProfiles;
      createFullComponent({
        propsData: {
          profiles: scannerProfiles,
          value: selectedProfile.id,
        },
      });
    });

    it('displays summary below dropdown', () => {
      const summary = findSelectedProfileSummary();

      expect(summary.exists()).toBe(true);
      expect(summary.text()).toContain(`${scannerProfiles[0].profileName}'s summary`);
    });

    it('displays item as checked', () => {
      expect(parseDropdownItems()).toEqual(
        scannerProfiles.map((x, i) => ({
          text: x.profileName,
          isChecked: i === 0,
        })),
      );
    });
  });
});
