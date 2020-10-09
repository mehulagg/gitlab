import Vuex from 'vuex';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import { GlDropdown, GlDropdownItem, GlSearchBoxByType, GlSkeletonLoader } from '@gitlab/ui';
import * as urlUtils from '~/lib/utils/url_utility';
import GroupFilter from '~/search/group_filter/components/group_filter.vue';
import { GROUP_QUERY_PARAM, PROJECT_QUERY_PARAM, ANY } from '~/search/group_filter/constants';
import { MOCK_GROUPS, MOCK_GROUP, MOCK_QUERY } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

jest.mock('~/flash');
jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn(),
  setUrlParams: jest.fn(),
}));

describe('Global Search Group Filter', () => {
  let wrapper;

  const actionSpies = {
    fetchGroups: jest.fn(),
    fetchInitialGroup: jest.fn(),
  };

  const createComponent = (initialState, mountFn = shallowMount) => {
    const store = new Vuex.Store({
      state: {
        query: MOCK_QUERY,
        ...initialState,
      },
      actions: actionSpies,
    });

    wrapper = mountFn(GroupFilter, {
      localVue,
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlDropdown = () => wrapper.find(GlDropdown);
  const findGlDropdownSearch = () => findGlDropdown().find(GlSearchBoxByType);
  const findDropdownText = () => findGlDropdown().find('.dropdown-toggle-text');
  const findDropdownItems = () => findGlDropdown().findAll(GlDropdownItem);
  const findDropdownItemsText = () => findDropdownItems().wrappers.map(w => w.text());
  const findAnyDropdownItem = () => findDropdownItems().at(0);
  const findFirstGroupDropdownItem = () => findDropdownItems().at(1);
  const findLoader = () => wrapper.find(GlSkeletonLoader);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders GlDropdown', () => {
      expect(findGlDropdown().exists()).toBe(true);
    });

    describe('findGlDropdownSearch', () => {
      it('renders always', () => {
        expect(findGlDropdownSearch().exists()).toBe(true);
      });

      it('has debounce prop', () => {
        expect(findGlDropdownSearch().attributes('debounce')).toBe('500');
      });

      describe('onSearch', () => {
        const groupSearch = 'test search';

        beforeEach(() => {
          findGlDropdownSearch().vm.$emit('input', groupSearch);
        });

        it('calls fetchGroups when input event is fired from GlSearchBoxByType', () => {
          expect(actionSpies.fetchGroups).toHaveBeenCalledWith(expect.any(Object), groupSearch);
        });
      });
    });

    describe('findDropdownItems', () => {
      describe('when fetchingGroups is false', () => {
        beforeEach(() => {
          createComponent({ groups: MOCK_GROUPS });
        });

        it('does not render loader', () => {
          expect(findLoader().exists()).toBe(false);
        });

        it('renders an instance for each namespace', () => {
          const groupsIncludingAny = ['Any'].concat(MOCK_GROUPS.map(n => n.full_name));
          expect(findDropdownItemsText()).toStrictEqual(groupsIncludingAny);
        });
      });

      describe('when fetchingGroups is true', () => {
        beforeEach(() => {
          createComponent({ fetchingGroups: true, groups: MOCK_GROUPS });
        });

        it('does render loader', () => {
          expect(findLoader().exists()).toBe(true);
        });

        it('renders only All in dropdown', () => {
          expect(findDropdownItemsText()).toStrictEqual(['Any']);
        });
      });
    });

    describe('Dropdown Text', () => {
      describe('when fetchingInitialGroup is true', () => {
        beforeEach(() => {
          createComponent({ fetchingInitialGroup: true }, mount);
        });

        it('sets dropdown text to Loading...', () => {
          expect(findDropdownText().text()).toBe('Loading...');
        });
      });

      describe('when fetchingInitialGroup is false and initialGroup is null', () => {
        beforeEach(() => {
          createComponent({}, mount);
        });

        it('sets dropdown text to Any', () => {
          expect(findDropdownText().text()).toBe(ANY.name);
        });
      });

      describe('when fetchingInitialGroup is false and initialGroup is set', () => {
        beforeEach(() => {
          createComponent({ initialGroup: MOCK_GROUP }, mount);
        });

        it('sets dropdown text to group name', () => {
          expect(findDropdownText().text()).toBe(MOCK_GROUP.name);
        });
      });
    });
  });

  describe('actions', () => {
    beforeEach(() => {
      createComponent({ groups: MOCK_GROUPS });
    });

    it('clicking "Any" dropdown item calls setUrlParams with group id null, project id null,and visitUrl', () => {
      findAnyDropdownItem().vm.$emit('click');

      expect(urlUtils.setUrlParams).toHaveBeenCalledWith({
        [GROUP_QUERY_PARAM]: ANY.id,
        [PROJECT_QUERY_PARAM]: null,
      });
      expect(urlUtils.visitUrl).toHaveBeenCalled();
    });

    it('clicking group dropdown item calls setUrlParams with group id, project id null, and visitUrl', () => {
      findFirstGroupDropdownItem().vm.$emit('click');

      expect(urlUtils.setUrlParams).toHaveBeenCalledWith({
        [GROUP_QUERY_PARAM]: MOCK_GROUPS[0].id,
        [PROJECT_QUERY_PARAM]: null,
      });
      expect(urlUtils.visitUrl).toHaveBeenCalled();
    });
  });

  describe('created', () => {
    describe('when group_id is set', () => {
      beforeEach(() => {
        createComponent({ query: { group_id: MOCK_GROUP.id } });
      });

      it('calls fetchInitialGroup with group id', () => {
        expect(actionSpies.fetchInitialGroup).toBeCalledWith(expect.any(Object), MOCK_GROUP.id);
      });
    });

    describe('when group_id is null', () => {
      beforeEach(() => {
        createComponent();
      });

      it('calls fetchInitialGroup with group id', () => {
        expect(actionSpies.fetchInitialGroup).not.toBeCalled();
      });
    });
  });
});
