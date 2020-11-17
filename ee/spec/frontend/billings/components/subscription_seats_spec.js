import { GlPagination } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import SubscriptionSeats from 'ee/billings/components/subscription_seats.vue';
import { mockDataSeats, seatsTableItems } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const actionSpies = {
  setNamespaceId: jest.fn(),
  fetchBillableMembersList: jest.fn(),
};

const tableProps = {
  namespaceName: 'Test Group Name',
  namespaceId: '1000',
};

const fakeStore = ({ initialState }) =>
  new Vuex.Store({
    modules: {
      seats: {
        namespaced: true,
        actions: actionSpies,
        state: {
          isLoading: false,
          hasError: false,
          ...initialState,
        },
      },
    },
  });

const createComponent = ({ props = {}, options = {}, initialState = {} } = {}) => {
  return shallowMount(SubscriptionSeats, {
    propsData: { ...tableProps, ...props },
    store: fakeStore({ initialState }),
    localVue,
    ...options,
    stubs: {
      GlTable: { template: '<div></div>', props: { items: Array, fields: Array, busy: Boolean } },
    },
  });
};

describe('Subscription Seats', () => {
  let wrapper;

  const findTable = () => wrapper.find('[data-testid="seats-table"]');
  const findHeading = () => wrapper.find('[data-testid="heading"]');
  const findPagination = () => wrapper.find(GlPagination);

  beforeEach(() => {
    wrapper = createComponent({
      initialState: {
        namespaceId: null,
        members: [...mockDataSeats.data],
        total: 300,
        page: 1,
        perPage: 5,
      },
    });
  });

  it('correct actions are called on create', () => {
    expect(actionSpies.setNamespaceId).toHaveBeenCalledWith(
      expect.any(Object),
      tableProps.namespaceId,
    );
    expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledWith(expect.any(Object), 1);
  });

  describe('heading text', () => {
    it('contains the group name and total seats number', () => {
      expect(findHeading().text()).toMatch(tableProps.namespaceName);
      expect(findHeading().text()).toMatch('300');
    });
  });

  describe('table', () => {
    it('is rendered and passed correct values', () => {
      expect(findTable().props('fields')).toEqual(['user']);
      expect(findTable().props('busy')).toBe(false);
      expect(findTable().props('items')).toEqual(seatsTableItems);
    });
  });

  describe('pagination', () => {
    it('is rendered and passed correct values', () => {
      expect(findPagination().vm.value).toBe(1);
      expect(findPagination().props('perPage')).toBe(5);
      expect(findPagination().props('totalItems')).toBe(300);
    });

    it.each([null, NaN, undefined, 'a string', false])(
      'will not render given %s for currentPage',
      value => {
        wrapper = createComponent({
          initialState: {
            namespaceId: null,
            members: [...mockDataSeats.data],
            total: 300,
            page: value,
            perPage: 5,
          },
        });
        expect(findPagination().exists()).toBe(false);
      },
    );
  });
});
