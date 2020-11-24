import { GlIcon, GlPopover, GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import IssuesBadge from 'ee/security_dashboard/components/issues_badge.vue';
import IssueLink from 'ee/vulnerabilities/components/issue_link.vue';

describe('Remediated badge component', () => {
  const issues = [{ issue: { iid: 41 } }, { issue: { iid: 591 } }];
  let wrapper;

  const findIcon = () => wrapper.find(GlIcon);
  const findBadge = () => wrapper.find(GlBadge);
  const findIssueLink = () => wrapper.findAll(IssueLink);
  const findPopover = () => wrapper.find(GlPopover);

  const createWrapper = ({ propsData }) => {
    return shallowMount(IssuesBadge, { propsData, stubs: { GlPopover, GlBadge } });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when there are multiple issues', () => {
    beforeEach(() => {
      wrapper = createWrapper({ propsData: { issues } });
    });

    it('displays the correct icon', () => {
      expect(findIcon().props('name')).toBe('issues');
    });

    it('links the badge and the popover', () => {
      const popover = wrapper.find({ ref: 'popover' });
      expect(popover.props('target')()).toEqual(findIcon().element.parentNode);
    });

    it('displays the issues', () => {
      expect(findIssueLink()).toHaveLength(issues.length);
    });

    it('displays the correct number of issues in the badge', () => {
      expect(findBadge().text()).toBe('2');
    });

    it('displays the correct number of issues in the popover title', () => {
      expect(findPopover().text()).toBe('2 Issues');
    });
  });

  describe('when there are no issues', () => {
    beforeEach(() => {
      wrapper = createWrapper({ propsData: { issues: [] } });
    });

    it('displays the correct number of issues in the badge', () => {
      expect(findBadge().text()).toBe('0');
    });

    it('displays the correct number of issues in the popover title', () => {
      expect(findPopover().text()).toBe('0 Issues');
    });
  });
});
