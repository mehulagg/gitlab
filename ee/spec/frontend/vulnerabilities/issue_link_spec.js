import { shallowMount } from '@vue/test-utils';
import IssueLink from 'ee/vulnerabilities/components/issue_link.vue';
import { getBinding, createMockDirective } from 'helpers/vue_mock_directive';

describe('IssueLink component', () => {
  let wrapper;

  const createIssue = options => ({
    title: 'my-issue',
    iid: 12,
    webUrl: 'http://localhost/issues/~/12',
    ...options,
  });

  const createWrapper = ({ propsData }) => {
    return shallowMount(IssueLink, {
      propsData,
      directives: {
        GlTooltip: createMockDirective(),
      },
    });
  };

  const findIssueLink = id => wrapper.find(`[data-testid="issue-link-${id}"]`);
  const findIssueWithState = state =>
    wrapper.find(state === 'opened' ? 'issue-open-m' : 'issue-close');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each`
    state       | icon
    ${'opened'} | ${'issue-open-m'}
    ${'closed'} | ${'issue-close'}
  `('when issue link is mounted', ({ state }) => {
    describe(`with state ${state}`, () => {
      const issue = createIssue({ state });

      beforeEach(() => {
        wrapper = createWrapper({ propsData: { issue } });
      });

      it('should contain the correct issue icon', () => {
        expect(findIssueWithState(state)).toBeTruthy();
      });

      it('should contain a link to the issue', () => {
        expect(findIssueLink(issue.iid).attributes('href')).toBe(issue.webUrl);
      });

      it('should contain the title', () => {
        const tooltip = getBinding(findIssueLink(issue.iid).element, 'gl-tooltip');
        expect(tooltip).toBeDefined();
        expect(tooltip.value).toBe(issue.title);
      });
    });
  });
});
