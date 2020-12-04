import { GlPagination, GlTable, GlAvatarLink, GlAvatarLabeled } from '@gitlab/ui';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import SubscriptionSeats from 'ee/billings/seat_usage/components/subscription_seats.vue';
import { mockDataSeats, mockTableItems } from 'ee_jest/billings/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const actionSpies = {
  setNamespaceId: jest.fn(),
  fetchBillableMembersList: jest.fn(),
};

const providedFields = {
  namespaceName: 'Test Group Name',
  namespaceId: '1000',
};

const fakeStore = ({ initialState, initialGetters }) =>
  new Vuex.Store({
    actions: actionSpies,
    getters: {
      tableItems: () => mockTableItems,
      ...initialGetters,
    },
    state: {
      isLoading: false,
      hasError: false,
      namespaceId: null,
      members: [...mockDataSeats.data],
      total: 300,
      page: 1,
      perPage: 5,
      ...providedFields,
      ...initialState,
    },
  });

describe('Subscription Seats', () => {
  let wrapper;

  const createComponent = ({
    initialState = {},
    mountFn = shallowMount,
    initialGetters = {},
  } = {}) => {
    return mountFn(SubscriptionSeats, {
      store: fakeStore({ initialState, initialGetters }),
      localVue,
    });
  };

  const findTable = () => wrapper.find(GlTable);
  const findPageHeading = () => wrapper.find('[data-testid="heading"]');
  const findPagination = () => wrapper.find(GlPagination);

  const serializeUser = rowWrapper => {
    const avatarLink = rowWrapper.find(GlAvatarLink);
    const avatarLabeled = rowWrapper.find(GlAvatarLabeled);

    return {
      avatarLink: {
        href: avatarLink.attributes('href'),
        alt: avatarLink.attributes('alt'),
      },
      avatarLabeled: {
        src: avatarLabeled.attributes('src'),
        size: avatarLabeled.attributes('size'),
        text: avatarLabeled.text(),
      },
    };
  };

  const serializeTableRow = rowWrapper => {
    const emailWrapper = rowWrapper.find('[data-testid="email"]');

    return {
      user: serializeUser(rowWrapper),
      email: emailWrapper.text(),
      tooltip: emailWrapper.find('span').attributes('title'),
    };
  };

  const findSerializedTable = tableWrapper => {
    return tableWrapper.findAll('tbody tr').wrappers.map(serializeTableRow);
  };

  describe('actions', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
      wrapper = null;
    });

    it('correct actions are called on create', () => {
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledWith(expect.any(Object), 1);
    });
  });

  describe('renders', () => {
    beforeEach(() => {
      wrapper = createComponent({
        mountFn: mount,
        initialGetters: {
          tableItems: () => mockTableItems,
        },
      });
    });

    afterEach(() => {
      wrapper.destroy();
      wrapper = null;
    });

    describe('heading text', () => {
      it('contains the group name and total seats number', () => {
        expect(findPageHeading().text()).toMatch(providedFields.namespaceName);
        expect(findPageHeading().text()).toMatch('300');
      });
    });

    describe('table content', () => {
      it('renders the correct data', () => {
        const serializedTable = findSerializedTable(wrapper.find(GlTable));

        expect(serializedTable).toMatchSnapshot();
      });
    });

    it('pagination is rendered and passed correct values', () => {
      expect(findPagination().vm.value).toBe(1);
      expect(findPagination().props('perPage')).toBe(5);
      expect(findPagination().props('totalItems')).toBe(300);
    });
  });

  describe('pagination', () => {
    it.each([null, NaN, undefined, 'a string', false])(
      'will not render given %s for currentPage',
      value => {
        wrapper = createComponent({
          initialState: {
            page: value,
          },
        });
        expect(findPagination().exists()).toBe(false);

        wrapper.destroy();
        wrapper = null;
      },
    );
  });

  describe('is loading', () => {
    beforeEach(() => {
      wrapper = createComponent({ initialState: { isLoading: true } });
    });

    afterEach(() => {
      wrapper.destroy();
      wrapper = null;
    });

    it('displays table in loading state', () => {
      expect(findTable().attributes('busy')).toBe('true');
    });
  });
});
