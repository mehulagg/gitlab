import { mount } from '@vue/test-utils';
import { within } from '@testing-library/dom';

import JiraIssueCreationVulnerabilities from '~/integrations/edit/components/jira_issue_creation_vulnerabilities.vue';

describe('JiraIssuesFields', () => {
  let wrapper;

  const defaultProps = {};

  const createComponent = props => {
    wrapper = mount(JiraIssueCreationVulnerabilities, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const withinComponent = () => within(wrapper.element);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  beforeEach(() => {
    createComponent();
  });

  it('should contain a heading', () => {
    expect(
      withinComponent().findByText(/enable jira issues creation from vulnerabilities/i),
    ).not.toBe(null);
  });

  it('should contain a help text that describes the feature', () => {
    expect(
      withinComponent().findByText(
        /issues created from vulnerabilities in this project will be jira issues, even if gitLab issues are enabled/i,
      ),
    ).not.toBe(null);
  });
});
