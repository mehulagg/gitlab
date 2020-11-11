import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { GlPagination, GlTable, GlAvatarLink, GlAvatarLabeled, GlLoadingIcon } from '@gitlab/ui';
import Vuex from 'vuex';
import SubscriptionSeats from 'ee/billings/seat_usage/components/subscription_seats.vue';
import { mockDataSeats } from 'ee_jest/billings/mock_data';

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

const fakeStore = ({ initialState }) =>
  new Vuex.Store({
    modules: {
      seats: {
        namespaced: true,
        actions: actionSpies,
        state: {
          isLoading: false,
          hasError: false,
          namespaceId: null,
          members: [...mockDataSeats.data],
          total: 300,
          page: 1,
          perPage: 5,
          ...initialState,
        },
      },
    },
  });

const createComponent = (initialState = {}, mountFn = shallowMount) => {
  return mountFn(SubscriptionSeats, {
    store: fakeStore({ initialState }),
    provide: {
      ...providedFields,
    },
    localVue,
  });
};

describe('Subscription Seats', () => {
  let wrapper;

  const findPageHeading = () => wrapper.find('[data-testid="heading"]');
  const findTable = () => wrapper.find(GlTable);
  const findTableHeaders = () => findTable().findAll('th');

  const findTableRow = index =>
    findTable()
      .findAll('tbody tr')
      .at(index);

  const findUserCol = rowIndex =>
    findTableRow(rowIndex)
      .findAll('td')
      .at(0);

  const findUserColAvatarLink = rowIndex => findUserCol(rowIndex).find(GlAvatarLink);
  const findUserColAvatarLabeled = rowIndex =>
    findUserColAvatarLink(rowIndex).find(GlAvatarLabeled);

  const findEmailCol = rowIndex =>
    findTableRow(rowIndex)
      .findAll('td')
      .at(1);

  const findPagination = () => wrapper.find(GlPagination);

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('correct actions are called on create', () => {
    expect(actionSpies.setNamespaceId).toHaveBeenCalledWith(
      expect.any(Object),
      providedFields.namespaceId,
    );
    expect(actionSpies.fetchBillableMembersList).toHaveBeenCalledWith(expect.any(Object), 1);
  });

  describe('heading text', () => {
    it('contains the group name and total seats number', () => {
      expect(findPageHeading().text()).toMatch(providedFields.namespaceName);
      expect(findPageHeading().text()).toMatch('300');
    });
  });

  describe('table', () => {
    beforeEach(() => {
      wrapper = createComponent({}, mount);
    });

    it('matches the snapshot', () => {
      expect(findTable().element).toMatchSnapshot();
    });

    it('renders the correct table headers', () => {
      const expectedValues = ['User', 'Email'];

      expect(findTableHeaders()).toHaveLength(2);
      expect(
        findTableHeaders()
          .at(0)
          .text(),
      ).toEqual(expectedValues[0]);
      expect(
        findTableHeaders()
          .at(1)
          .text(),
      ).toEqual(expectedValues[1]);
    });

    describe('when data is loading', () => {
      beforeEach(() => {
        wrapper = createComponent({ isLoading: true }, mount);
      });

      it('displays a busy state', () => {
        expect(findTable().attributes('aria-busy')).toBe('true');
      });

      it('displays a loading icon', () => {
        expect(
          findTable()
            .find(GlLoadingIcon)
            .exists(),
        ).toBe(true);
      });

      it('matches the snapshot', () => {
        expect(findTable().element).toMatchSnapshot();
      });
    });

    describe('when data is not loading', () => {
      beforeEach(() => {
        wrapper = createComponent({ isLoading: false }, mount);
      });

      it('does not display a busy state', () => {
        expect(findTable().attributes('aria-busy')).toBe('false');
      });

      it('does not display a loading icon', () => {
        expect(
          findTable()
            .find(GlLoadingIcon)
            .exists(),
        ).toBe(false);
      });
    });

    it('user column gets correct data passed', () => {
      const { web_url, name, username, avatar_url } = mockDataSeats.data[0];

      expect(findUserColAvatarLink(0).attributes('href')).toMatch(web_url);
      expect(findUserColAvatarLink(0).attributes('alt')).toMatch(name);

      expect(findUserColAvatarLabeled(0).props('label')).toMatch(name);
      expect(findUserColAvatarLabeled(0).props('subLabel')).toMatch(`@${username}`);
      expect(findUserColAvatarLabeled(0).attributes('src')).toMatch(avatar_url);
    });

    describe('email column', () => {
      it('displays only one span element at a time', () => {
        expect(findEmailCol(0).findAll('span').length).toBe(1);
        expect(findEmailCol(2).findAll('span').length).toBe(1);
      });

      it('email column shows actual email when data is passed', () => {
        const { email } = mockDataSeats.data[0];

        expect(
          findEmailCol(0)
            .find('span')
            .text(),
        ).toBe(email);
      });

      it('email column shows custom text when data is not passed', () => {
        expect(
          findEmailCol(2)
            .find('span')
            .text(),
        ).toBe('Private');
      });
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
          page: value,
        });
        expect(findPagination().exists()).toBe(false);
      },
    );
  });
});
