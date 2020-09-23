import * as types from 'ee/vue_shared/security_reports/store/modules/sast/mutation_types';
import createState from 'ee/vue_shared/security_reports/store/modules/sast/state';
import mutations from 'ee/vue_shared/security_reports/store/modules/sast/mutations';

const createIssue = ({ ...config }) => ({ changed: false, ...config });

describe('sast module mutations', () => {
  const path = 'path';
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(types.SET_DIFF_ENDPOINT, () => {
    it('should set the SAST diff endpoint', () => {
      mutations[types.SET_DIFF_ENDPOINT](state, path);

      expect(state.paths.diffEndpoint).toBe(path);
    });
  });

  describe(types.REQUEST_DIFF, () => {
    it('should set the `isLoading` status to `true`', () => {
      mutations[types.REQUEST_DIFF](state);

      expect(state.isLoading).toBe(true);
    });
  });

  describe(types.UPDATE_VULNERABILITY, () => {
    let newIssue;
    let resolvedIssue;
    let allIssue;

    beforeEach(() => {
      newIssue = createIssue({ project_fingerprint: 'new' });
      resolvedIssue = createIssue({ project_fingerprint: 'resolved' });
      allIssue = createIssue({ project_fingerprint: 'all' });

      state.newIssues.push(newIssue);
      state.resolvedIssues.push(resolvedIssue);
      state.allIssues.push(allIssue);
    });

    describe('with a `new` issue', () => {
      beforeEach(() => {
        mutations[types.UPDATE_VULNERABILITY](state, { ...newIssue, changed: true });
      });

      it('should update the correct issue', () => {
        expect(state.newIssues[0].changed).toBe(true);
      });
    });

    describe('with a `resolved` issue', () => {
      beforeEach(() => {
        mutations[types.UPDATE_VULNERABILITY](state, { ...resolvedIssue, changed: true });
      });

      it('should update the correct issue', () => {
        expect(state.resolvedIssues[0].changed).toBe(true);
      });
    });

    describe('with an `all` issue', () => {
      beforeEach(() => {
        mutations[types.UPDATE_VULNERABILITY](state, { ...allIssue, changed: true });
      });

      it('should update the correct issue', () => {
        expect(state.allIssues[0].changed).toBe(true);
      });
    });

    describe('with an invalid issue', () => {
      beforeEach(() => {
        mutations[types.UPDATE_VULNERABILITY](
          state,
          createIssue({ project_fingerprint: 'invalid', changed: true }),
        );
      });

      it('should ignore the issue', () => {
        expect(state.newIssues[0].changed).toBe(false);
        expect(state.resolvedIssues[0].changed).toBe(false);
        expect(state.allIssues[0].changed).toBe(false);
      });
    });
  });

  describe(types.RECEIVE_DIFF_SUCCESS, () => {
    beforeEach(() => {
      const reports = {
        diff: {
          added: [
            createIssue({ cve: 'CVE-1' }),
            createIssue({ cve: 'CVE-2' }),
            createIssue({ cve: 'CVE-3' }),
          ],
          fixed: [createIssue({ cve: 'CVE-4' }), createIssue({ cve: 'CVE-5' })],
          existing: [createIssue({ cve: 'CVE-6' })],
          base_report_out_of_date: true,
        },
      };
      state.isLoading = true;
      mutations[types.RECEIVE_DIFF_SUCCESS](state, reports);
    });

    it('should set the `isLoading` status to `false`', () => {
      expect(state.isLoading).toBe(false);
    });

    it('should set the `baseReportOutofDate` status to `false`', () => {
      expect(state.baseReportOutofDate).toBe(true);
    });

    it('should have the relevant `new` issues', () => {
      expect(state.newIssues).toHaveLength(3);
    });

    it('should have the relevant `resolved` issues', () => {
      expect(state.resolvedIssues).toHaveLength(2);
    });

    it('should have the relevant `all` issues', () => {
      expect(state.allIssues).toHaveLength(1);
    });
  });

  describe(types.RECEIVE_DIFF_ERROR, () => {
    beforeEach(() => {
      state.isLoading = true;
      mutations[types.RECEIVE_DIFF_ERROR](state);
    });

    it('should set the `isLoading` status to `false`', () => {
      expect(state.isLoading).toBe(false);
    });

    it('should set the `hasError` status to `true`', () => {
      expect(state.hasError).toBe(true);
    });
  });
});
