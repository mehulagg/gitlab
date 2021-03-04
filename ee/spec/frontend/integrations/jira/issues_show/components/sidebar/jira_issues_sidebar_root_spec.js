import { shallowMount } from '@vue/test-utils';
import Assignee from 'ee/integrations/jira/issues_show/components/sidebar/assignee.vue';
import IssueDueDate from 'ee/integrations/jira/issues_show/components/sidebar/issue_due_date.vue';
import IssueReference from 'ee/integrations/jira/issues_show/components/sidebar/issue_reference.vue';
import Sidebar from 'ee/integrations/jira/issues_show/components/sidebar/jira_issues_sidebar_root.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';
import { mockJiraIssue as mockJiraIssueData } from '../../mock_data';

const mockJiraIssue = convertObjectPropsToCamelCase(mockJiraIssueData, { deep: true });

describe('JiraIssuesSidebar', () => {
  let wrapper;

  const defaultProps = {
    sidebarExpanded: false,
    issue: mockJiraIssue,
  };

  const createComponent = ({ props = {} } = {}) => {
    wrapper = shallowMount(Sidebar, {
      propsData: { ...defaultProps, ...props },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findLabelsSelect = () => wrapper.findComponent(LabelsSelect);
  const findAssignee = () => wrapper.findComponent(Assignee);
  const findIssueDueDate = () => wrapper.findComponent(IssueDueDate);
  const findIssueReference = () => wrapper.findComponent(IssueReference);

  it('renders Labels block', () => {
    createComponent();

    expect(findLabelsSelect().props('selectedLabels')).toBe(mockJiraIssue.labels);
  });

  it('renders Assignee block', () => {
    createComponent();
    const assignee = findAssignee();

    expect(assignee.props('assignee')).toBe(mockJiraIssue.assignees[0]);
  });

  it('renders IssueDueDate', () => {
    createComponent();
    const dueDate = findIssueDueDate();

    expect(dueDate.props('dueDate')).toBe(mockJiraIssue.dueDate);
  });

  describe('when references.relative is null', () => {
    it('does not render IssueReference', () => {
      createComponent({
        props: {
          issue: {
            references: {},
          },
        },
      });

      expect(findIssueReference().exists()).toBe(false);
    });
  });

  describe('when references.relative is provided', () => {
    it('renders IssueReference', () => {
      createComponent();

      expect(findIssueReference().exists()).toBe(true);
    });
  });
});
