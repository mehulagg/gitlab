import { shallowMount } from '@vue/test-utils';

import IssueReference from 'ee/integrations/jira/issues_show/components/issue_reference.vue';
import Sidebar from 'ee/integrations/jira/issues_show/components/sidebar.vue';
import LabelsSelect from '~/vue_shared/components/sidebar/labels_select_vue/labels_select_root.vue';

import { mockJiraIssue } from '../mock_data';

describe('Sidebar', () => {
  let wrapper;

  const defaultProps = {
    sidebarExpanded: false,
    selectedLabels: mockJiraIssue.labels,
    reference: mockJiraIssue.references.relative,
  };

  const createComponent = () => {
    wrapper = shallowMount(Sidebar, {
      propsData: defaultProps,
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findLabelsSelect = () => wrapper.findComponent(LabelsSelect);
  const findIssueReference = () => wrapper.findComponent(IssueReference);

  it('renders LabelsSelect', () => {
    createComponent();

    expect(findLabelsSelect().exists()).toBe(true);
  });

  it('renders IssueReference', () => {
    createComponent();

    expect(findIssueReference().exists()).toBe(true);
  });
});
