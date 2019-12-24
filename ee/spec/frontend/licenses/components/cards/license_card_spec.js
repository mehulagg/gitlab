import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { LicenseCard } from 'ee/licenses/components/cards';

describe('LicenseCard', () => {
  let wrapper;
  let actions;
  const defaultProps = {
    license: {
      id: 1,
      plan: 'super duper',
    },
    isCurrentLicense: false,
  };
  const defaultState = {
    activeUserCount: 10,
    guestUserCount: 8,
    deleteQueue: [],
    downloadLicensePath: '/downloadLicensePath',
  };

  const localVue = createLocalVue();
  localVue.use(Vuex);

  function createStore(newState) {
    const state = Object.assign({}, defaultState, newState);
    actions = { fetchDeleteLicense: jest.fn() };

    return new Vuex.Store({ state, actions });
  }

  function createComponent(state, props) {
    const propsData = Object.assign({}, defaultProps, props);

    wrapper = shallowMount(LicenseCard, {
      sync: false,
      store: createStore(state),
      propsData,
      localVue,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders license card with a delete button and license body', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });
});
