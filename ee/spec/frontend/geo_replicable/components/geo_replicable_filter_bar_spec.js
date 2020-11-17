import { GlDropdown, GlDropdownItem, GlSearchBoxByType, GlButton } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoReplicableFilterBar from 'ee/geo_replicable/components/geo_replicable_filter_bar.vue';
import { DEFAULT_SEARCH_DELAY } from 'ee/geo_replicable/constants';
import { getStoreConfig } from 'ee/geo_replicable/store';
import { MOCK_REPLICABLE_TYPE } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoReplicableFilterBar', () => {
  let wrapper;

  const actionSpies = {
    setSearch: jest.fn(),
    setFilter: jest.fn(),
    fetchReplicableItems: jest.fn(),
    initiateAllReplicableSyncs: jest.fn(),
  };

  const createComponent = () => {
    const fakeStore = new Vuex.Store({
      ...getStoreConfig({ replicableType: MOCK_REPLICABLE_TYPE, graphqlFieldName: null }),
      actions: actionSpies,
    });
    wrapper = shallowMount(GeoReplicableFilterBar, {
      localVue,
      store: fakeStore,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findNavContainer = () => wrapper.find('nav');
  const findGlDropdown = () => findNavContainer().find(GlDropdown);
  const findGlDropdownItems = () => findNavContainer().findAll(GlDropdownItem);
  const findDropdownItemsText = () => findGlDropdownItems().wrappers.map(w => w.text());
  const findGlSearchBox = () => findNavContainer().find(GlSearchBoxByType);
  const findGlButton = () => findNavContainer().find(GlButton);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders nav container always', () => {
      expect(findNavContainer().exists()).toBeTruthy();
    });

    it('renders dropdown always', () => {
      expect(findGlDropdown().exists()).toBeTruthy();
    });

    describe('Filter options', () => {
      it('renders a dropdown item for each filterOption', () => {
        expect(findDropdownItemsText()).toStrictEqual(
          wrapper.vm.filterOptions.map(n => {
            if (n.label === 'All') {
              return `${n.label} ${MOCK_REPLICABLE_TYPE}`;
            }

            return n.label;
          }),
        );
      });

      it('clicking a dropdown item calls setFilter with its index', () => {
        const index = 1;
        findGlDropdownItems()
          .at(index)
          .vm.$emit('click');

        expect(actionSpies.setFilter).toHaveBeenCalledWith(expect.any(Object), index);
      });
    });

    describe('Search box', () => {
      it('renders always', () => {
        expect(findGlSearchBox().exists()).toBe(true);
      });

      it('has debounce prop', () => {
        expect(findGlSearchBox().attributes('debounce')).toBe(DEFAULT_SEARCH_DELAY.toString());
      });

      describe('onSearch', () => {
        const testSearch = 'test search';

        beforeEach(() => {
          findGlSearchBox().vm.$emit('input', testSearch);
        });

        it('calls fetchSyncNamespaces when input event is fired from GlSearchBoxByType', () => {
          expect(actionSpies.setSearch).toHaveBeenCalledWith(expect.any(Object), testSearch);
          expect(actionSpies.fetchReplicableItems).toHaveBeenCalled();
        });
      });
    });

    describe('Re-sync all button', () => {
      it('renders always', () => {
        expect(findGlButton().exists()).toBeTruthy();
      });

      it('calls initiateAllReplicableSyncs when clicked', () => {
        findGlButton().vm.$emit('click');
        expect(actionSpies.initiateAllReplicableSyncs).toHaveBeenCalled();
      });
    });
  });

  describe('filterChange', () => {
    const testValue = 2;

    beforeEach(() => {
      createComponent();
      wrapper.vm.filterChange(testValue);
    });

    it('should call setFilter with the filterIndex', () => {
      expect(actionSpies.setFilter).toHaveBeenCalledWith(expect.any(Object), testValue);
    });

    it('should call fetchReplicableItems', () => {
      expect(actionSpies.fetchReplicableItems).toHaveBeenCalled();
    });
  });
});
