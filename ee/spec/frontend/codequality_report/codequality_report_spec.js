import { mount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import CodequalityReportApp from 'ee/codequality_report/codequality_report.vue';
import { parsedIssues } from './mock_data';
import Api from '~/api';

jest.mock('~/api.js');
jest.mock('~/flash');

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Codequality report app', () => {
  let wrapper;
  let store;

  const createComponent = (state = {}, issues = [], glFeatures = {}) => {
    store = new Vuex.Store({
      state: {
        pageInfo: {},
        ...state,
      },
      getters: {
        codequalityIssues: () => issues,
        codequalityIssueTotal: () => issues.length,
      },
    });

    wrapper = mount(CodequalityReportApp, {
      localVue,
      store,
      provide: {
        glFeatures,
      },
    });
  };

  const findStatus = () => wrapper.find('.js-code-text');
  const findSuccessIcon = () => wrapper.find('.js-ci-status-icon-success');
  const findWarningIcon = () => wrapper.find('.js-ci-status-icon-warning');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ isLoadingCodequality: true });
    });

    it('shows a loading state', () => {
      expect(findStatus().text()).toBe('Loading codeclimate report');
    });
  });

  describe('on error', () => {
    beforeEach(() => {
      createComponent({ loadingCodequalityFailed: true });
    });

    it('shows a warning icon and error message', () => {
      expect(findWarningIcon().exists()).toBe(true);
      expect(findStatus().text()).toBe('Failed to load codeclimate report');
    });
  });

  describe('when there are codequality issues', () => {
    beforeEach(() => {
      createComponent({}, parsedIssues);
    });

    it('renders the codequality issues', () => {
      const expectedIssueTotal = parsedIssues.length;

      expect(findWarningIcon().exists()).toBe(true);
      expect(findStatus().text()).toContain(`Found ${expectedIssueTotal} code quality issues`);
      expect(findStatus().text()).toContain(
        `This report contains all Code Quality issues in the source branch.`,
      );
      expect(wrapper.findAll('.report-block-list-issue')).toHaveLength(expectedIssueTotal);
    });

    it('renders a link to the line where the issue was found', () => {
      const issueLink = wrapper.find('.report-block-list-issue a');

      expect(issueLink.text()).toBe('ee/spec/features/admin/geo/admin_geo_projects_spec.rb:152');
      expect(issueLink.attributes('href')).toBe(
        '/root/test-codequality/blob/feature-branch/ee/spec/features/admin/geo/admin_geo_projects_spec.rb#L152',
      );
    });
  });

  describe('when there are no codequality issues', () => {
    beforeEach(() => {
      createComponent({}, []);
    });

    it('shows a message that no codequality issues were found', () => {
      expect(findSuccessIcon().exists()).toBe(true);
      expect(findStatus().text()).toBe('No code quality issues found');
      expect(wrapper.findAll('.report-block-list-issue')).toHaveLength(0);
    });
  });

  describe('usage ping tracking', () => {
    describe('with feature flag enabled', () => {
      it('tracks an event when mounted', () => {
        createComponent({}, [], { usageDataITestingFullCodeQualityReportTotal: true });

        expect(Api.trackRedisHllUserEvent).toHaveBeenCalledWith(wrapper.vm.$options.mountEvent);
      });
    });

    describe('with feature flag disabled', () => {
      it('does not track an event when mounted', () => {
        createComponent({}, [], { usageDataIFullCodeQualityReportTotal: false });

        expect(Api.trackRedisHllUserEvent).not.toHaveBeenCalled();
      });
    });
  });
});
