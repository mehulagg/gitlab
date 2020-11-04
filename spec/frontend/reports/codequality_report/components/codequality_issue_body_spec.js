import { shallowMount } from '@vue/test-utils';
import { GlBadge } from '@gitlab/ui';
import component from '~/reports/codequality_report/components/codequality_issue_body.vue';
import { STATUS_FAILED, STATUS_NEUTRAL, STATUS_SUCCESS } from '~/reports/constants';

describe('code quality issue body issue body', () => {
  let wrapper;

  const findBadge = () => wrapper.find(GlBadge);

  const codequalityIssue = {
    name:
      'rubygem-rest-client: session fixation vulnerability via Set-Cookie headers in 30x redirection responses',
    path: 'Gemfile.lock',
    severity: 'normal',
    type: 'Issue',
    urlPath: '/Gemfile.lock#L22',
  };

  const createComponent = (initialStatus, issue = codequalityIssue) => {
    wrapper = shallowMount(component, {
      propsData: {
        issue,
        status: initialStatus,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('severity rating', () => {
    it.each`
      severity      | badgeVariant | badgeIcon
      ${'info'}     | ${'info'}    | ${null}
      ${'minor'}    | ${'neutral'} | ${null}
      ${'major'}    | ${'warning'} | ${null}
      ${'critical'} | ${'danger'}  | ${null}
      ${'blocker'}  | ${'danger'}  | ${'cancel'}
    `(
      'renders correct badge and icon for "$severity" severity rating',
      ({ severity, badgeVariant, badgeIcon }) => {
        createComponent(STATUS_FAILED, {
          ...codequalityIssue,
          severity,
        });

        const badge = findBadge();

        expect(badge.props('variant')).toBe(badgeVariant);
        expect(badge.props('icon')).toBe(badgeIcon);
      },
    );
  });

  describe('with success', () => {
    it('renders fixed label', () => {
      createComponent(STATUS_SUCCESS);

      expect(wrapper.text()).toContain('Fixed');
    });
  });

  describe('without success', () => {
    it('does not render fixed label', () => {
      createComponent(STATUS_FAILED);

      expect(wrapper.text()).not.toContain('Fixed');
    });
  });

  describe('name', () => {
    it('renders name', () => {
      createComponent(STATUS_NEUTRAL);

      expect(wrapper.text()).toContain(codequalityIssue.name);
    });
  });

  describe('path', () => {
    it('renders the report-link path using the correct code quality issue', () => {
      createComponent(STATUS_NEUTRAL);

      expect(wrapper.find('report-link-stub').props('issue')).toBe(codequalityIssue);
    });
  });
});
