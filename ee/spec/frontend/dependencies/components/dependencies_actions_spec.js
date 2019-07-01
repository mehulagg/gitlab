import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import { TEST_HOST } from 'helpers/test_constants';
import createStore from 'ee/dependencies/store';
import { DEPENDENCY_LIST_TYPES } from 'ee/dependencies/store/constants';
import { SORT_FIELDS } from 'ee/dependencies/store/modules/list/constants';
import DependenciesActions from 'ee/dependencies/components/dependencies_actions.vue';

describe('DependenciesActions component', () => {
  let store;
  let wrapper;
  const listType = DEPENDENCY_LIST_TYPES.all;

  const factory = (props = {}) => {
    const localVue = createLocalVue();

    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(localVue.extend(DependenciesActions), {
      localVue,
      store,
      sync: false,
      propsData: { ...props },
    });
  };

  beforeEach(() => {
    factory({ namespace: listType });
    store.state[listType].endpoint = `${TEST_HOST}/dependencies`;
    return wrapper.vm.$nextTick();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('dispatches the right setSortField action on clicking each item in the dropdown', () => {
    const dropdownItems = wrapper.findAll(GlDropdownItem).wrappers;

    dropdownItems.forEach(item => {
      // trigger() does not work on stubbed/shallow mounted components
      // https://github.com/vuejs/vue-test-utils/issues/919
      item.vm.$emit('click');
    });

    expect(store.dispatch.mock.calls).toEqual(
      expect.arrayContaining(
        Object.keys(SORT_FIELDS).map(field => [`${listType}/setSortField`, field]),
      ),
    );
  });

  it('dispatches the toggleSortOrder action on clicking the sort order button', () => {
    const sortButton = wrapper.find('.js-sort-order');
    sortButton.vm.$emit('click');
    expect(store.dispatch).toHaveBeenCalledWith(`${listType}/toggleSortOrder`);
  });

  it('has a button to export the dependency list', () => {
    const download = wrapper.find('.js-download');
    expect(download.attributes()).toEqual(
      expect.objectContaining({
        href: store.getters[`${listType}/downloadEndpoint`],
        download: expect.any(String),
      }),
    );
  });
});
