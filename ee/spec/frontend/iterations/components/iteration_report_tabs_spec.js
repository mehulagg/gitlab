import { GlAlert, GlAvatar, GlLoadingIcon, GlPagination, GlTable, GlTab } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import IterationReportTabs from 'ee/iterations/components/iteration_report_tabs.vue';
import { Namespace } from 'ee/iterations/constants';

describe('Iterations report tabs', () => {
  let wrapper;
  const id = 3;
  const fullPath = 'gitlab-org';
  const defaultProps = {
    fullPath,
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const mountComponent = ({ props = defaultProps, loading = false, data = {} } = {}) => {
    wrapper = mount(IterationReportTabs, {
      propsData: props,
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          queries: { issues: { loading } },
        },
      },
      stubs: {
        GlAvatar,
        GlTab,
        GlTable,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('shows spinner while loading', () => {
    mountComponent({
      loading: true,
    });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    expect(wrapper.find(GlTable).exists()).toBe(false);
  });

  it('shows iterations list when not loading', () => {
    mountComponent({
      loading: false,
    });

    expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    expect(wrapper.find(GlTable).exists()).toBe(true);
    expect(wrapper.text()).toContain('No issues found');
  });

  it('shows error in a gl-alert', () => {
    const error = 'Oh no!';

    mountComponent({
      data: {
        error,
      },
    });

    expect(wrapper.find(GlAlert).text()).toContain(error);
  });

  describe('with issues', () => {
    const pageSize = 20;
    const totalIssues = pageSize + 1;

    const assignees = Array(totalIssues)
      .fill(null)
      .map((_, i) => ({
        id: i,
        name: `User ${i}`,
        username: `user${i}`,
        state: 'active',
        avatarUrl: 'http://invalid/avatar.png',
        webUrl: `https://localhost:3000/user${i}`,
      }));

    const issues = Array(totalIssues)
      .fill(null)
      .map((_, i) => ({
        id: i,
        title: `Issue ${i}`,
        assignees: assignees.slice(0, i),
      }));

    const findIssues = () => wrapper.findAll('table tbody tr');
    const findAssigneesForIssue = index =>
      findIssues()
        .at(index)
        .findAll(GlAvatar);

    beforeEach(() => {
      mountComponent();

      wrapper.setData({
        issues: {
          list: issues,
          pageInfo: {
            hasNextPage: true,
            hasPreviousPage: false,
            startCursor: 'first-item',
            endCursor: 'last-item',
          },
          count: issues.length,
        },
      });
    });

    it('shows issue list in table', () => {
      expect(wrapper.find(GlTable).exists()).toBe(true);
      expect(findIssues()).toHaveLength(issues.length);
    });

    it('shows assignees', () => {
      expect(findAssigneesForIssue(0)).toHaveLength(0);
      expect(findAssigneesForIssue(1)).toHaveLength(1);
      expect(findAssigneesForIssue(10)).toHaveLength(10);
    });

    describe('pagination', () => {
      const findPagination = () => wrapper.find(GlPagination);
      const setPage = page => {
        findPagination().vm.$emit('input', page);
        return findPagination().vm.$nextTick();
      };

      it('passes prev, next, and current page props', () => {
        expect(findPagination().exists()).toBe(true);
        expect(findPagination().props()).toEqual(
          expect.objectContaining({
            value: wrapper.vm.pagination.currentPage,
            prevPage: wrapper.vm.prevPage,
            nextPage: wrapper.vm.nextPage,
          }),
        );
      });

      it('updates query variables when going to previous page', () => {
        return setPage(1).then(() => {
          expect(wrapper.vm.queryVariables).toEqual({
            beforeCursor: 'first-item',
            fullPath,
            id,
            lastPageSize: 20,
            isGroup: true,
          });
        });
      });

      it('updates query variables when going to next page', () => {
        return setPage(2).then(() => {
          expect(wrapper.vm.queryVariables).toEqual({
            afterCursor: 'last-item',
            fullPath,
            id,
            firstPageSize: 20,
            isGroup: true,
          });
        });
      });
    });
  });

  describe('IterationReportTabs query variables', () => {
    const expected = {
      afterCursor: undefined,
      firstPageSize: 20,
      fullPath: defaultProps.fullPath,
      id,
    };

    describe('when group', () => {
      it('has expected query variable values', () => {
        mountComponent({
          props: {
            ...defaultProps,
            namespaceType: Namespace.Group,
          },
        });

        expect(wrapper.vm.queryVariables).toEqual({
          ...expected,
          isGroup: true,
        });
      });
    });

    describe('when project', () => {
      it('has expected query variable values', () => {
        mountComponent({
          props: {
            ...defaultProps,
            namespaceType: Namespace.Project,
          },
        });

        expect(wrapper.vm.queryVariables).toEqual({
          ...expected,
          isGroup: false,
        });
      });
    });
  });
});
