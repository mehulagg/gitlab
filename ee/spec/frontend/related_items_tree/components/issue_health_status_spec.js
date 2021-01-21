import { shallowMount } from '@vue/test-utils';

import IssueHealthStatus from 'ee/related_items_tree/components/issue_health_status.vue';
import { issueHealthStatus, issueHealthStatusCSSMapping } from 'ee/related_items_tree/constants';
import { mockIssue1 } from '../mock_data';

const createComponent = () => {
  const { healthStatus } = mockIssue1;

  return shallowMount(IssueHealthStatus, {
    propsData: {
      healthStatus,
    },
  });
};

describe('IssueHealthStatus', () => {
  let wrapper;
  const { healthStatus } = mockIssue1;
  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders passed in healthStatus', () => {
    const expectedValue = issueHealthStatus[healthStatus];

    expect(wrapper.text()).toBe(expectedValue);
  });

  it('applies correct class for passed in healthStatus', () => {
    const expectedValue = issueHealthStatusCSSMapping[healthStatus];

    expect(wrapper.find(`.${expectedValue}`)).toExist();
  });
});
