import { nextTick } from 'vue';
import Vuex from 'vuex';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { merge } from 'lodash';
import Filters from 'ee/security_dashboard/components/filters.vue';
import LoadingError from 'ee/security_dashboard/components/loading_error.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import SecurityDashboardTable from 'ee/security_dashboard/components/security_dashboard_table.vue';
import SecurityDashboard from 'ee/security_dashboard/components/security_dashboard_vuex.vue';

import { getStoreConfig } from 'ee/security_dashboard/store';
import IssueModal from 'ee/vue_shared/security_reports/components/modal.vue';
import { TEST_HOST } from 'helpers/test_constants';
import axios from '~/lib/utils/axios_utils';

const pipelineId = 123;
const vulnerabilitiesEndpoint = `${TEST_HOST}/vulnerabilities`;

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('Security Dashboard component', () => {
  let wrapper;
  let mock;
  let setPipelineIdSpy;
  let fetchPipelineJobsSpy;
  let store;

  const createComponent = (props) => {
    setPipelineIdSpy = jest.fn();
    fetchPipelineJobsSpy = jest.fn();

    const { actions, ...storeConfig } = getStoreConfig();
    store = new Vuex.Store(
      merge(storeConfig, {
        modules: {
          vulnerabilities: { actions: { setPipelineId: setPipelineIdSpy } },
          pipelineJobs: { actions: { fetchPipelineJobs: fetchPipelineJobsSpy } },
        },
      }),
    );

    wrapper = shallowMount(SecurityDashboard, {
      store,
      stubs: {
        SecurityDashboardLayout,
      },
      propsData: {
        dashboardDocumentation: '',
        vulnerabilitiesEndpoint,
        pipelineId,
        ...props,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
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

    it('sets the pipeline id', () => {
      expect(setPipelineIdSpy).toHaveBeenCalledWith(expect.any(Object), pipelineId);
    });

    it('fetchs the pipeline jobs', () => {
      expect(fetchPipelineJobsSpy).toHaveBeenCalledWith(expect.any(Object), undefined);
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
      ${'revertDismissVulnerability'}        | ${undefined} | ${'vulnerabilities/revertDismissVulnerability'} | ${{ vulnerability: 'bar' }}
      ${'downloadPatch'}                     | ${undefined} | ${'vulnerabilities/downloadPatch'}              | ${{ vulnerability: 'bar' }}
    `(
      'dispatches the "$expectedDispatchedAction" action when the modal emits a "$emittedModalEvent" event',
      ({ emittedModalEvent, eventPayload, expectedDispatchedAction, expectedActionPayload }) => {
        store.state.vulnerabilities.modal.vulnerability = 'bar';

        jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());
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
      async ({ givenState, expectedProps }) => {
        createComponent();
        Object.assign(store.state.vulnerabilities, givenState);
        await nextTick();

        expect(wrapper.find(IssueModal).props()).toStrictEqual(expectedProps);
      },
    );
  });

  describe('on error', () => {
    beforeEach(() => {
      createComponent();
    });

    it.each([401, 403])('displays an error on error %s', async (errorCode) => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      await nextTick();
      expect(wrapper.find(LoadingError).exists()).toBe(true);
    });

    it.each([404, 500])('does not display an error on error %s', async (errorCode) => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      await nextTick();
      expect(wrapper.find(LoadingError).exists()).toBe(false);
    });
  });
});
