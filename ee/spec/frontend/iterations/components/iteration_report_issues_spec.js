import {
  GlAlert,
  GlAvatar,
  GlBadge,
  GlButton,
  GlLabel,
  GlLoadingIcon,
  GlPagination,
  GlTable,
} from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import IterationReportIssues from 'ee/iterations/components/iteration_report_issues.vue';
import { Namespace } from 'ee/iterations/constants';

describe('Iterations report issues', () => {
  let wrapper;
  const id = 3;
  const fullPath = 'gitlab-org';
  const label = {
    id: 17,
    title: 'Bug',
    color: '#123456',
    description: 'Bug label description',
    scoped: false,
  };
  const defaultProps = {
    fullPath,
    iterationId: `gid://gitlab/Iteration/${id}`,
  };

  const findGlBadge = () => wrapper.find(GlBadge);
  const findGlButton = () => wrapper.find(GlButton);
  const findGlLabel = () => wrapper.find(GlLabel);
  const findGlLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findGlPagination = () => wrapper.find(GlPagination);
  const findGlTable = () => wrapper.find(GlTable);

  const mountComponent = ({
    props = defaultProps,
    loading = false,
    data = {},
    mountFunction = shallowMount,
  } = {}) => {
    wrapper = mountFunction(IterationReportIssues, {
      propsData: props,
      data() {
        return data;
      },
      mocks: {
        $apollo: {
          queries: { issues: { loading } },
        },
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

    expect(findGlLoadingIcon().exists()).toBe(true);
    expect(findGlTable().isVisible()).toBe(false);
  });

  it('shows iterations list when not loading', () => {
    mountComponent({ loading: false, mountFunction: mount });

    expect(findGlLoadingIcon().isVisible()).toBe(false);
    expect(findGlTable().exists()).toBe(true);
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
    const findAssigneesForIssue = (index) => findIssues().at(index).findAll(GlAvatar);

    describe('issue_list', () => {
      beforeEach(() => {
        const data = {
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
        };

        mountComponent({ data, mountFunction: mount });
      });

      it('shows issue list in table', () => {
        expect(findGlTable().exists()).toBe(true);
        expect(findIssues()).toHaveLength(issues.length);
      });

      it('shows assignees', () => {
        expect(findAssigneesForIssue(0)).toHaveLength(0);
        expect(findAssigneesForIssue(1)).toHaveLength(1);
        expect(findAssigneesForIssue(10)).toHaveLength(10);
      });
    });

    describe('pagination', () => {
      beforeEach(() => {
        const data = {
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
        };

        mountComponent({ data });
      });

      const findPagination = () => wrapper.find(GlPagination);
      const setPage = (page) => {
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

  describe('label grouping header', () => {
    describe('when a label is provided', () => {
      const count = 4;

      beforeEach(() => {
        mountComponent({
          props: { ...defaultProps, label },
          data: { issues: { count } },
        });
      });

      it('shows button to expand/collapse the table', () => {
        expect(findGlButton().props('icon')).toBe('chevron-down');
        expect(findGlButton().attributes('aria-label')).toBe('Collapse');
      });

      it('shows label with the label title', () => {
        expect(findGlLabel().props()).toEqual(
          expect.objectContaining({
            backgroundColor: label.color,
            description: label.description,
            scoped: label.scoped,
            title: label.title,
          }),
        );
      });

      it('shows badge with issue count', () => {
        expect(findGlBadge().text()).toBe(count.toString());
      });
    });

    describe('when a label is not provided', () => {
      beforeEach(() => {
        mountComponent();
      });

      it('hides button to expand/collapse the table', () => {
        expect(findGlButton().exists()).toBe(false);
      });

      it('hides label with the label title', () => {
        expect(findGlLabel().exists()).toBe(false);
      });

      it('hides badge with issue count', () => {
        expect(findGlBadge().exists()).toBe(false);
      });
    });
  });

  describe('expand/collapse behaviour', () => {
    describe('when expanded', () => {
      beforeEach(() => {
        mountComponent({
          props: { ...defaultProps, label },
          data: { isExpanded: true },
        });
      });

      it('hides the issues when the `Collapse` button is clicked', async () => {
        expect(findGlButton().props('icon')).toBe('chevron-down');
        expect(findGlButton().attributes('aria-label')).toBe('Collapse');
        expect(findGlTable().isVisible()).toBe(true);
        expect(findGlPagination().isVisible()).toBe(true);

        await findGlButton().vm.$emit('click');

        expect(findGlButton().props('icon')).toBe('chevron-right');
        expect(findGlButton().attributes('aria-label')).toBe('Expand');
        expect(findGlTable().isVisible()).toBe(false);
        expect(findGlPagination().isVisible()).toBe(false);
      });
    });

    describe('when collapsed', () => {
      beforeEach(() => {
        mountComponent({
          props: { ...defaultProps, label },
          data: { isExpanded: false },
        });
      });

      it('shows the issues when the `Expand` button is clicked', async () => {
        expect(findGlButton().props('icon')).toBe('chevron-right');
        expect(findGlButton().attributes('aria-label')).toBe('Expand');
        expect(findGlTable().isVisible()).toBe(false);
        expect(findGlPagination().isVisible()).toBe(false);

        await findGlButton().vm.$emit('click');

        expect(findGlButton().props('icon')).toBe('chevron-down');
        expect(findGlButton().attributes('aria-label')).toBe('Collapse');
        expect(findGlTable().isVisible()).toBe(true);
        expect(findGlPagination().isVisible()).toBe(true);
      });
    });
  });
});
