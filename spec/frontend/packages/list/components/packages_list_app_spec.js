import { GlEmptyState, GlSprintf, GlLink } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import createFlash from '~/flash';
import * as commonUtils from '~/lib/utils/common_utils';
import PackageSearch from '~/packages/list/components/package_search.vue';
import PackageListApp from '~/packages/list/components/packages_list_app.vue';
import { DELETE_PACKAGE_SUCCESS_MESSAGE } from '~/packages/list/constants';
import { SHOW_DELETE_SUCCESS_ALERT } from '~/packages/shared/constants';
import * as packageUtils from '~/packages_and_registries/shared/utils';

jest.mock('~/lib/utils/common_utils');
jest.mock('~/flash');

const localVue = createLocalVue();
localVue.use(Vuex);

describe('packages_list_app', () => {
  let wrapper;
  let store;

  const PackageList = {
    name: 'package-list',
    template: '<div><slot name="empty-state"></slot></div>',
  };
  const GlLoadingIcon = { name: 'gl-loading-icon', template: '<div>loading</div>' };

  const emptyListHelpUrl = 'helpUrl';
  const findEmptyState = () => wrapper.find(GlEmptyState);
  const findListComponent = () => wrapper.find(PackageList);
  const findPackageSearch = () => wrapper.find(PackageSearch);

  const createStore = (filter = []) => {
    store = new Vuex.Store({
      state: {
        isLoading: false,
        config: {
          resourceId: 'project_id',
          emptyListIllustration: 'helpSvg',
          emptyListHelpUrl,
          packageHelpUrl: 'foo',
        },
        filter,
      },
    });
    store.dispatch = jest.fn();
  };

  const mountComponent = () => {
    wrapper = shallowMount(PackageListApp, {
      localVue,
      store,
      stubs: {
        GlEmptyState,
        GlLoadingIcon,
        PackageList,
        GlSprintf,
        GlLink,
      },
    });
  };

  beforeEach(() => {
    createStore();
    jest.spyOn(packageUtils, 'getQueryParams').mockReturnValue({});
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders', () => {
    mountComponent();
    expect(wrapper.element).toMatchSnapshot();
  });

  it('call requestPackagesList on page:changed', () => {
    mountComponent();
    store.dispatch.mockClear();

    const list = findListComponent();
    list.vm.$emit('page:changed', 1);
    expect(store.dispatch).toHaveBeenCalledWith('requestPackagesList', { page: 1 });
  });

  it('call requestDeletePackage on package:delete', () => {
    mountComponent();

    const list = findListComponent();
    list.vm.$emit('package:delete', 'foo');
    expect(store.dispatch).toHaveBeenCalledWith('requestDeletePackage', 'foo');
  });

  it('does call requestPackagesList only one time on render', () => {
    mountComponent();

    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenNthCalledWith(1, 'setSorting', expect.any(Object));
    expect(store.dispatch).toHaveBeenNthCalledWith(2, 'setFilter', expect.any(Array));
    expect(store.dispatch).toHaveBeenNthCalledWith(3, 'requestPackagesList');
  });

  describe('url query string handling', () => {
    const defaultQueryParamsMock = {
      search: [1, 2],
      type: 'npm',
      sort: 'asc',
      orderBy: 'created',
    };

    it('calls setSorting with the query string based sorting', () => {
      jest.spyOn(packageUtils, 'getQueryParams').mockReturnValue(defaultQueryParamsMock);

      mountComponent();

      expect(store.dispatch).toHaveBeenNthCalledWith(1, 'setSorting', {
        orderBy: defaultQueryParamsMock.orderBy,
        sort: defaultQueryParamsMock.sort,
      });
    });

    it('calls setFilter with the query string based filters', () => {
      jest.spyOn(packageUtils, 'getQueryParams').mockReturnValue(defaultQueryParamsMock);

      mountComponent();

      expect(store.dispatch).toHaveBeenNthCalledWith(2, 'setFilter', [
        { type: 'type', value: { data: defaultQueryParamsMock.type } },
        { type: 'filtered-search-term', value: { data: defaultQueryParamsMock.search[0] } },
        { type: 'filtered-search-term', value: { data: defaultQueryParamsMock.search[1] } },
      ]);
    });

    it.each`
      sort         | orderBy      | payload
      ${'foo'}     | ${undefined} | ${{ sort: 'foo' }}
      ${undefined} | ${'bar'}     | ${{ orderBy: 'bar' }}
      ${'foo'}     | ${'bar'}     | ${{ sort: 'foo', orderBy: 'bar' }}
      ${undefined} | ${undefined} | ${{}}
    `(
      'with sort equal to $sort, orderBy equal to $orderBy, setSorting is called with $payload',
      ({ sort, orderBy, payload }) => {
        jest.spyOn(packageUtils, 'getQueryParams').mockReturnValue({ sort, orderBy });

        mountComponent();

        expect(store.dispatch).toHaveBeenNthCalledWith(1, 'setSorting', payload);
      },
    );

    it.each`
      search       | type         | payload
      ${undefined} | ${undefined} | ${[]}
      ${['one']}   | ${undefined} | ${[{ type: 'filtered-search-term', value: { data: 'one' } }]}
      ${['one']}   | ${'foo'}     | ${[{ type: 'type', value: { data: 'foo' } }, { type: 'filtered-search-term', value: { data: 'one' } }]}
      ${undefined} | ${'foo'}     | ${[{ type: 'type', value: { data: 'foo' } }]}
    `(
      'with search equal to $search, type equal to $type, setSorting is called with $payload',
      ({ search, type, payload }) => {
        jest.spyOn(packageUtils, 'getQueryParams').mockReturnValue({ search, type });

        mountComponent();

        expect(store.dispatch).toHaveBeenNthCalledWith(2, 'setFilter', payload);
      },
    );
  });

  describe('empty state', () => {
    it('generate the correct empty list link', () => {
      mountComponent();

      const link = findListComponent().find(GlLink);

      expect(link.attributes('href')).toBe(emptyListHelpUrl);
      expect(link.text()).toBe('publish and share your packages');
    });

    it('includes the right content on the default tab', () => {
      mountComponent();

      const heading = findEmptyState().find('h1');

      expect(heading.text()).toBe('There are no packages yet');
    });
  });

  describe('filter without results', () => {
    beforeEach(() => {
      createStore([{ type: 'something' }]);
      mountComponent();
    });

    it('should show specific empty message', () => {
      expect(findEmptyState().text()).toContain('Sorry, your filter produced no results');
      expect(findEmptyState().text()).toContain(
        'To widen your search, change or remove the filters above',
      );
    });
  });

  describe('Package Search', () => {
    it('exists', () => {
      mountComponent();

      expect(findPackageSearch().exists()).toBe(true);
    });

    it('on update fetches data from the store', () => {
      mountComponent();
      store.dispatch.mockClear();

      findPackageSearch().vm.$emit('update');

      expect(store.dispatch).toHaveBeenCalledWith('requestPackagesList');
    });
  });

  describe('delete alert handling', () => {
    const { location } = window.location;
    const search = `?${SHOW_DELETE_SUCCESS_ALERT}=true`;

    beforeEach(() => {
      createStore();
      jest.spyOn(commonUtils, 'historyReplaceState').mockImplementation(() => {});
      delete window.location;
      window.location = {
        href: `foo_bar_baz${search}`,
        search,
      };
    });

    afterEach(() => {
      window.location = location;
    });

    it(`creates a flash if the query string contains ${SHOW_DELETE_SUCCESS_ALERT}`, () => {
      mountComponent();

      expect(createFlash).toHaveBeenCalledWith({
        message: DELETE_PACKAGE_SUCCESS_MESSAGE,
        type: 'notice',
      });
    });

    it('calls historyReplaceState with a clean url', () => {
      mountComponent();

      expect(commonUtils.historyReplaceState).toHaveBeenCalledWith('foo_bar_baz');
    });

    it(`does nothing if the query string does not contain ${SHOW_DELETE_SUCCESS_ALERT}`, () => {
      window.location.search = '';
      mountComponent();

      expect(createFlash).not.toHaveBeenCalled();
      expect(commonUtils.historyReplaceState).not.toHaveBeenCalled();
    });
  });
});
