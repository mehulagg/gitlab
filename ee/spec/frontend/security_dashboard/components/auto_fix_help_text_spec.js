import { mount } from '@vue/test-utils';
import AutoFixHelpText from 'ee/security_dashboard/components/auto_fix_help_text.vue';

describe('AutoFix Help Text component', () => {
  let wrapper;
  const createWrapper = ({ props = {}, listeners } = {}) => {
    return mount(AutoFixHelpText, {
      propsData: {
        popoverId: 'randomString',
        mergeRequests: {
          nodes: [
            {
              merge_request: {
                url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48820',
                status: 'status_warning',
                auto_fix: true,
                __typename: 'mergeRequestDetail',
              },
              __typename: 'mergeRequest',
            },
            {
              merge_request: {
                url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48821',
                status: 'merge',
                auto_fix: false,
                __typename: 'mergeRequestDetail',
              },
              __typename: 'mergeRequest',
            },
            {
              merge_request: {
                url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48822',
                status: 'status_canceled',
                auto_fix: true,
                __typename: 'mergeRequestDetail',
              },
              __typename: 'mergeRequest',
            },
          ],
          __typename: 'mergeRequestLinks',
        },
        ...props,
      },
      stubs: {
        GlPopover: true,
      },
      listeners,
      provide: () => ({}),
    });
  };

  const findAutoFixBulb = () => wrapper.find('[data-testid="vulnerability-solutions-bulb"]');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('Auto Fix Help Text Component', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    it('should display autoFixIcon on render', () => {
      expect(findAutoFixBulb).toExist();
    });
  });
});
