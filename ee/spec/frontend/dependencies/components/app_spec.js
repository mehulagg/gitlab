import { createLocalVue, shallowMount } from '@vue/test-utils';
import { TEST_HOST } from 'helpers/test_constants';
import createStore from 'ee/dependencies/store';
import { REPORT_STATUS } from 'ee/dependencies/store/constants';
import DependenciesApp from 'ee/dependencies/components/app.vue';
import DependenciesTable from 'ee/dependencies/components/dependencies_table.vue';
import Pagination from '~/vue_shared/components/pagination_links.vue';

describe('DependenciesApp component', () => {
  test.todo('needs testing');

  let store;
  let wrapper;

  const basicAppProps = {
    endpoint: '/foo',
    emptyStateSvgPath: '/bar.svg',
    documentationPath: TEST_HOST,
  };

  const factory = (props = basicAppProps) => {
    const localVue = createLocalVue();

    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(localVue.extend(DependenciesApp), {
      localVue,
      store,
      sync: false,
      propsData: { ...props },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on creation', () => {
    beforeEach(() => {
      factory();
    });

    it('dispatches the correct initial actions', () => {
      expect(store.dispatch.mock.calls).toEqual([
        ['setDependenciesEndpoint', basicAppProps.endpoint],
        ['fetchDependencies'],
      ]);
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    describe('given a list of dependencies and ok report', () => {
      let dependencies;

      beforeEach(() => {
        dependencies = ['foo', 'bar'];

        Object.assign(store.state, {
          initialized: true,
          isLoading: false,
          dependencies,
        });
        store.state.pageInfo.total = 100;
        store.state.reportInfo.status = REPORT_STATUS.ok;

        return wrapper.vm.$nextTick();
      });

      it('matches the snapshot', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('passes the correct props to the dependencies table', () => {
        const table = wrapper.find(DependenciesTable);
        expect(table.isVisible()).toBe(true);
        expect(table.props()).toEqual(
          expect.objectContaining({
            dependencies,
            isLoading: false,
          }),
        );
      });

      it('passes the correct props to the pagination', () => {
        const pagination = wrapper.find(Pagination);
        expect(pagination.isVisible()).toBe(true);
        expect(pagination.props()).toEqual(
          expect.objectContaining({
            pageInfo: store.state.pageInfo,
            change: wrapper.vm.fetchPage,
          }),
        );
      });
    });
  });

  test.todo('renders empty state');
  test.todo('renders job failure');
  test.todo('renders incomplete job');
  test.todo('renders error');
});
