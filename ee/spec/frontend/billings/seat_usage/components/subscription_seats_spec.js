import {
  GlPagination,
  GlTable,
  GlAvatarLink,
  GlAvatarLabeled,
  GlSearchBoxByType,
  GlBadge,
} from '@gitlab/ui';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import SubscriptionSeats from 'ee/billings/seat_usage/components/subscription_seats.vue';
import { mockDataSeats, mockTableItems } from 'ee_jest/billings/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

const actionSpies = {
  fetchBillableMembersList: jest.fn(),
  resetMembers: jest.fn(),
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
  const findTableEmptyText = () => findTable().attributes('empty-text');

  const findPageHeading = () => wrapper.find('[data-testid="heading-info"]');
  const findPageHeadingText = () => findPageHeading().find('[data-testid="heading-info-text"]');
  const findPageHeadingBadge = () => findPageHeading().find(GlBadge);

  const findSearchBox = () => wrapper.find(GlSearchBoxByType);
  const findPagination = () => wrapper.find(GlPagination);

  const serializeUser = (rowWrapper) => {
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

  const serializeTableRow = (rowWrapper) => {
    const emailWrapper = rowWrapper.find('[data-testid="email"]');

    return {
      user: serializeUser(rowWrapper),
      email: emailWrapper.text(),
      tooltip: emailWrapper.find('span').attributes('title'),
    };
  };

  const findSerializedTable = (tableWrapper) => {
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
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalled();
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
        expect(findPageHeadingText().text()).toMatch(providedFields.namespaceName);
        expect(findPageHeadingBadge().text()).toMatch('300');
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
      (value) => {
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

  describe('search box', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('input event triggers the fetchBillableMembersList action', async () => {
      const SEARCH_STRING = 'search string';

      // fetchBillableMembersList is called once on created()
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', SEARCH_STRING);

      // fetchBillableMembersList is triggered a second time on input
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(2);

      // fetchBillableMembersList is triggered the second time with the correct argument
      expect(actionSpies.fetchBillableMembersList.mock.calls[1][1]).toEqual({
        search: SEARCH_STRING,
      });
    });
  });

  describe('typing inside of the search box', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('causes the empty table text to change based on the number of typed characters', async () => {
      const EMPTY_TEXT_TOO_SHORT = 'Enter at least three characters to search.';
      const EMPTY_TEXT_NO_USERS = 'No users to display.';

      expect(findTableEmptyText()).toBe(EMPTY_TEXT_TOO_SHORT);

      await findSearchBox().vm.$emit('input', 'a');
      expect(findTableEmptyText()).toBe(EMPTY_TEXT_TOO_SHORT);

      await findSearchBox().vm.$emit('input', 'aa');
      expect(findTableEmptyText()).toBe(EMPTY_TEXT_TOO_SHORT);

      await findSearchBox().vm.$emit('input', 'aaa');
      expect(findTableEmptyText()).toBe(EMPTY_TEXT_NO_USERS);
    });

    it('dispatches the resetMembers action when 1 or 2 characters have been typed', async () => {
      expect(actionSpies.resetMembers).not.toHaveBeenCalled();

      await findSearchBox().vm.$emit('input', 'a');
      expect(actionSpies.resetMembers).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', 'aa');
      expect(actionSpies.resetMembers).toHaveBeenCalledTimes(2);

      await findSearchBox().vm.$emit('input', 'aaa');
      expect(actionSpies.resetMembers).toHaveBeenCalledTimes(2);
    });

    it('dispatches fetchBillableMembersList action when search box is emptied out', async () => {
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', 'a');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', '');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(2);
    });

    it('dispatches fetchBillableMembersList action when more than 2 characters are typed', async () => {
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', 'a');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', 'aa');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(1);

      await findSearchBox().vm.$emit('input', 'aaa');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(2);

      await findSearchBox().vm.$emit('input', 'aaaa');
      expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledTimes(3);
    });
  });
});
