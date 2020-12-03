import { mount, createLocalVue } from '@vue/test-utils';
import { within } from '@testing-library/dom';
import Vuex from 'vuex';
import { GlDropdownItem } from '@gitlab/ui';
import SortDropdown from '~/members/components/filter_sort/sort_dropdown.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('SortDropdown', () => {
  let wrapper;

  const createComponent = state => {
    const store = new Vuex.Store({
      state: {
        sourceId: 1,
        tableSortableFields: ['account', 'granted', 'expires', 'maxRole', 'lastSignIn'],
        filteredSearchBar: {
          show: true,
          tokens: ['two_factor'],
          searchParam: 'search',
          placeholder: 'Filter members',
          recentSearchesStorageKey: 'group_members',
        },
        ...state,
      },
    });

    wrapper = mount(SortDropdown, {
      localVue,
      store,
    });
  };

  const findDropdownToggle = () => wrapper.find('button[aria-haspopup="true"]');
  const findDropdownItemByText = text =>
    wrapper
      .findAll(GlDropdownItem)
      .wrappers.find(dropdownItemWrapper => dropdownItemWrapper.text() === text);

  describe('dropdown options', () => {
    beforeEach(() => {
      delete window.location;
      window.location = new URL('https://localhost');
    });

    it('adds dropdown items for all the sortable fields', () => {
      window.location.search = '?two_factor=enabled&search=foobar';

      const expectedDropdownItems = [
        {
          label: 'Account, ascending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=name_asc',
        },
        {
          label: 'Account, descending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=name_desc',
        },
        {
          label: 'Access granted, ascending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=last_joined',
        },
        {
          label: 'Access granted, descending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=oldest_joined',
        },
        {
          label: 'Max role, ascending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=access_level_asc',
        },
        {
          label: 'Max role, descending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=access_level_desc',
        },
        {
          label: 'Last sign-in, ascending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=recent_sign_in',
        },
        {
          label: 'Last sign-in, descending',
          url: 'https://localhost/?two_factor=enabled&search=foobar&sort=oldest_sign_in',
        },
      ];

      createComponent();

      expectedDropdownItems.forEach(expectedDropdownItem => {
        const dropdownItem = findDropdownItemByText(expectedDropdownItem.label);

        expect(dropdownItem).not.toBe(null);
        expect(dropdownItem.find('a').attributes('href')).toBe(expectedDropdownItem.url);
      });
    });

    it('checks selected sort option', () => {
      window.location.search = '?sort=access_level_asc';

      createComponent();

      expect(findDropdownItemByText('Max role, ascending').props('isChecked')).toBe(true);
    });
  });

  describe('dropdown toggle', () => {
    beforeEach(() => {
      delete window.location;
      window.location = new URL('https://localhost');
    });

    it('defaults to sorting by "Account, ascending"', () => {
      createComponent();

      expect(findDropdownToggle().text()).toBe('Account, ascending');
    });

    it('sets text as selected sort option', () => {
      window.location.search = '?sort=access_level_asc';

      createComponent();

      expect(findDropdownToggle().text()).toBe('Max role, ascending');
    });
  });

  it('renders dropdown label', () => {
    createComponent();

    expect(within(wrapper.element).queryByText('Sort by')).not.toBe(null);
  });
});
