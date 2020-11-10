import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { TEST_HOST } from 'helpers/test_constants';

import SecurityDashboard from 'ee/security_dashboard/components/security_dashboard_vuex.vue';
import Filters from 'ee/security_dashboard/components/filters.vue';
import IssueModal from 'ee/vue_shared/security_reports/components/modal.vue';
import SecurityDashboardTable from 'ee/security_dashboard/components/security_dashboard_table.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import VulnerabilityChart from 'ee/security_dashboard/components/vulnerability_chart.vue';
import LoadingError from 'ee/security_dashboard/components/loading_error.vue';

import createStore from 'ee/security_dashboard/store';
import axios from '~/lib/utils/axios_utils';

const pipelineId = 123;
const vulnerabilitiesEndpoint = `${TEST_HOST}/vulnerabilities`;
const vulnerabilitiesHistoryEndpoint = `${TEST_HOST}/vulnerabilities_history`;

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('Security Dashboard component', () => {
  let wrapper;
  let mock;
  let setPipelineIdSpy;
  let fetchPipelineJobsSpy;
  let store;

  const createComponent = props => {
    wrapper = shallowMount(SecurityDashboard, {
      store,
      stubs: {
        SecurityDashboardLayout,
      },
      methods: {
        setPipelineId: setPipelineIdSpy,
        fetchPipelineJobs: fetchPipelineJobsSpy,
      },
      propsData: {
        dashboardDocumentation: '',
        vulnerabilitiesEndpoint,
        vulnerabilitiesHistoryEndpoint,
        pipelineId,
        ...props,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    setPipelineIdSpy = jest.fn();
    fetchPipelineJobsSpy = jest.fn();
    store = createStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
    jest.clearAllMocks();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the filters', () => {
      expect(wrapper.find(Filters).exists()).toBe(true);
    });

    it('renders the security dashboard table ', () => {
      expect(wrapper.find(SecurityDashboardTable).exists()).toBe(true);
    });

    it('renders the vulnerability chart', () => {
      expect(wrapper.find(VulnerabilityChart).exists()).toBe(true);
    });

    it('sets the pipeline id', () => {
      expect(setPipelineIdSpy).toHaveBeenCalledWith(pipelineId);
    });

    it('fetchs the pipeline jobs', () => {
      expect(fetchPipelineJobsSpy).toHaveBeenCalledWith();
    });

    it('renders the issue modal', () => {
      expect(wrapper.find(IssueModal).exists()).toBe(true);
    });

    it.each`
      emittedModalEvent                      | eventPayload | expectedDispatchedAction                        | expectedActionPayload
      ${'addDismissalComment'}               | ${'foo'}     | ${'vulnerabilities/addDismissalComment'}        | ${{ comment: 'foo', vulnerability: 'bar' }}
      ${'editVulnerabilityDismissalComment'} | ${undefined} | ${'vulnerabilities/openDismissalCommentBox'}    | ${undefined}
      ${'showDismissalDeleteButtons'}        | ${undefined} | ${'vulnerabilities/showDismissalDeleteButtons'} | ${undefined}
      ${'hideDismissalDeleteButtons'}        | ${undefined} | ${'vulnerabilities/hideDismissalDeleteButtons'} | ${undefined}
      ${'deleteDismissalComment'}            | ${undefined} | ${'vulnerabilities/deleteDismissalComment'}     | ${{ vulnerability: 'bar' }}
      ${'closeDismissalCommentBox'}          | ${undefined} | ${'vulnerabilities/closeDismissalCommentBox'}   | ${undefined}
      ${'createMergeRequest'}                | ${undefined} | ${'vulnerabilities/createMergeRequest'}         | ${{ vulnerability: 'bar' }}
      ${'createNewIssue'}                    | ${undefined} | ${'vulnerabilities/createIssue'}                | ${{ vulnerability: 'bar' }}
      ${'dismissVulnerability'}              | ${'bar'}     | ${'vulnerabilities/dismissVulnerability'}       | ${{ comment: 'bar', vulnerability: 'bar' }}
      ${'openDismissalCommentBox'}           | ${undefined} | ${'vulnerabilities/openDismissalCommentBox'}    | ${undefined}
      ${'revertDismissVulnerability'}        | ${undefined} | ${'vulnerabilities/undoDismiss'}                | ${{ vulnerability: 'bar' }}
      ${'downloadPatch'}                     | ${undefined} | ${'vulnerabilities/downloadPatch'}              | ${{ vulnerability: 'bar' }}
    `(
      'dispatches the "$expectedDispatchedAction" action when the modal emits a "$emittedModalEvent" event',
      ({ emittedModalEvent, eventPayload, expectedDispatchedAction, expectedActionPayload }) => {
        wrapper.vm.$store.state.vulnerabilities.modal.vulnerability = 'bar';

        jest.spyOn(store, 'dispatch').mockImplementation();
        wrapper.find(IssueModal).vm.$emit(emittedModalEvent, eventPayload);

        expect(store.dispatch).toHaveBeenCalledWith(
          expectedDispatchedAction,
          expectedActionPayload,
        );
      },
    );
  });

  describe('issue modal', () => {
    it.each`
      givenState                                                                                   | expectedProps
      ${{ modal: { vulnerability: 'foo' } }}                                                       | ${{ modal: { vulnerability: 'foo' }, canCreateIssue: false, canCreateMergeRequest: false, canDismissVulnerability: false, isCreatingIssue: false, isDismissingVulnerability: false, isCreatingMergeRequest: false }}
      ${{ modal: { vulnerability: { create_vulnerability_feedback_issue_path: 'foo' } } }}         | ${expect.objectContaining({ canCreateIssue: true })}
      ${{ modal: { vulnerability: { create_vulnerability_feedback_merge_request_path: 'foo' } } }} | ${expect.objectContaining({ canCreateMergeRequest: true })}
      ${{ modal: { vulnerability: { create_vulnerability_feedback_dismissal_path: 'foo' } } }}     | ${expect.objectContaining({ canDismissVulnerability: true })}
      ${{ isCreatingIssue: true }}                                                                 | ${expect.objectContaining({ isCreatingIssue: true })}
      ${{ isDismissingVulnerability: true }}                                                       | ${expect.objectContaining({ isDismissingVulnerability: true })}
      ${{ isCreatingMergeRequest: true }}                                                          | ${expect.objectContaining({ isCreatingMergeRequest: true })}
    `(
      'passes right props to issue modal with state $givenState',
      ({ givenState, expectedProps }) => {
        Object.assign(store.state.vulnerabilities, givenState);

        createComponent();

        expect(wrapper.find(IssueModal).props()).toStrictEqual(expectedProps);
      },
    );
  });

  describe.each`
    endpointProp                        | Component
    ${'vulnerabilitiesHistoryEndpoint'} | ${VulnerabilityChart}
  `('with an empty $endpointProp', ({ endpointProp, Component }) => {
    beforeEach(() => {
      createComponent({
        [endpointProp]: '',
      });
    });

    it(`does not show the ${Component.name}`, () => {
      expect(wrapper.find(Component).exists()).toBe(false);
    });
  });

  describe('on error', () => {
    beforeEach(() => {
      createComponent();
    });

    it.each([401, 403])('displays an error on error %s', errorCode => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(LoadingError).exists()).toBe(true);
      });
    });

    it.each([404, 500])('does not display an error on error %s', errorCode => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(LoadingError).exists()).toBe(false);
      });
    });
  });
});
