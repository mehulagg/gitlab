import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import JiraIssuesShow from 'ee/integrations/jira/issues_show/components/jira_issues_show_root.vue';
import { issueStates } from 'ee/integrations/jira/issues_show/constants';
import waitForPromises from 'helpers/wait_for_promises';
import IssuableHeader from '~/issuable_show/components/issuable_header.vue';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';
import axios from '~/lib/utils/axios_utils';
import { mockJiraIssue } from '../mock_data';

const mockJiraIssuesShowPath = 'jira_issues_show_path';

describe('JiraIssuesShow', () => {
  let wrapper;
  let mockAxios;

  const findIssuableShow = () => wrapper.findComponent(IssuableShow);
  const findIssuableShowStatusBadge = () =>
    wrapper.findComponent(IssuableHeader).find('[data-testid="status"]');

  const createComponent = () => {
    wrapper = shallowMount(JiraIssuesShow, {
      stubs: {
        IssuableShow,
        IssuableHeader,
      },
      provide: {
        issuesShowPath: mockJiraIssuesShowPath,
      },
    });
  };

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();

    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('renders IssuableShow', async () => {
    mockAxios.onGet(mockJiraIssuesShowPath).replyOnce(200, mockJiraIssue);
    createComponent();

    await waitForPromises();
    await wrapper.vm.$nextTick();

    expect(findIssuableShow().exists()).toBe(true);
  });

  describe.each`
    state                 | statusIcon              | statusBadgeClass             | badgeText
    ${issueStates.OPENED} | ${'issue-open-m'}       | ${'status-box-open'}         | ${'Open'}
    ${issueStates.CLOSED} | ${'mobile-issue-close'} | ${'status-box-issue-closed'} | ${'Closed'}
  `('when issue state is `$state`', async ({ state, statusIcon, statusBadgeClass, badgeText }) => {
    beforeEach(async () => {
      mockAxios.onGet(mockJiraIssuesShowPath).replyOnce(200, { ...mockJiraIssue, state });
      createComponent();

      await waitForPromises();
      await wrapper.vm.$nextTick();
    });

    it('sets `statusIcon` prop correctly', () => {
      expect(findIssuableShow().props('statusIcon')).toBe(statusIcon);
    });

    it('sets `statusBadgeClass` prop correctly', () => {
      expect(findIssuableShow().props('statusBadgeClass')).toBe(statusBadgeClass);
    });

    it('renders correct status badge text', () => {
      expect(findIssuableShowStatusBadge().text()).toBe(badgeText);
    });
  });
});
