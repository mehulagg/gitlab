import { shallowMount } from '@vue/test-utils';

import JiraIssuesShow from 'ee/integrations/jira/issues_show/components/jira_issues_show_root.vue';
import IssuableShow from '~/issuable_show/components/issuable_show_root.vue';

import { mockJiraIssue } from '../mock_data';

jest.mock('ee/integrations/jira/issues_show/api', () => ({
  fetchIssue: jest.fn().mockImplementation(() => mockJiraIssue),
}));

describe('JiraIssuesShow', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(JiraIssuesShow, {
      stubs: {
        IssuableShow,
      },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findIssuableShow = () => wrapper.findComponent(IssuableShow);

  it('renders IssuableShow', async () => {
    createComponent();

    await wrapper.vm.$nextTick();

    expect(findIssuableShow().exists()).toBe(true);
  });
});
