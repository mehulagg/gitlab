import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import InstanceCardsList from 'ee/licenses/components/license_cards_list.vue';
import * as getters from 'ee/licenses/store/getters';
import createState from 'ee/licenses/store/state';

describe('InstanceCardsList', () => {
  const newLicensePath = '/newLicensePath';
  let wrapper;

  const localVue = createLocalVue();
  localVue.use(Vuex);

  function createStore(store) {
    const state = Object.assign(createState(), store, {
      newLicensePath,
    });

    return new Vuex.Store({ state, getters });
  }

  function createComponent(store) {
    wrapper = shallowMount(InstanceCardsList, {
      sync: false,
      store: createStore(store),
      localVue,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a list of license cards', () => {
    createComponent({ licenses: [{ id: 1 }, { id: 2 }], isLoadingLicenses: false });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a skeleton loading card if loading licenses', () => {
    createComponent({ isLoadingLicenses: true });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a message when there are no licenses', () => {
    createComponent({ licenses: [], isLoadingLicenses: false });

    expect(wrapper.element).toMatchSnapshot();
  });
});
