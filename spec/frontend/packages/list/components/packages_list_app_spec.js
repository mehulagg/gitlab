import { GlEmptyState, GlSprintf, GlLink } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import createFlash from '~/flash';
import * as commonUtils from '~/lib/utils/common_utils';
import PackageSearch from '~/packages/list/components/package_search.vue';
import PackageListApp from '~/packages/list/components/packages_list_app.vue';
import { DELETE_PACKAGE_SUCCESS_MESSAGE } from '~/packages/list/constants';
import { SHOW_DELETE_SUCCESS_ALERT } from '~/packages/shared/constants';

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
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders', () => {
    mountComponent();
    expect(wrapper.element).toMatchSnapshot();
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

  it('does not call requestPackagesList two times on render', () => {
    mountComponent();

    expect(store.dispatch).toHaveBeenCalledTimes(1);
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
