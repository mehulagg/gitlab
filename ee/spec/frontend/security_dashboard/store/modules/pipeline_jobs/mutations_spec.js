import * as types from 'ee/security_dashboard/store/modules/pipeline_jobs/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/pipeline_jobs/mutations';

describe('pipeline jobs module mutations', () => {
  let state;

  beforeEach(() => {
    state = {};
  });

  describe('SET_PIPELINE_JOBS_PATH', () => {
    const pipelineJobsPath = 123;

    it(`should set the pipelineJobsPath to ${pipelineJobsPath}`, () => {
      mutations[types.SET_PIPELINE_JOBS_PATH](state, pipelineJobsPath);
      expect(state.pipelineJobsPath).toBe(pipelineJobsPath);
    });
  });

  describe('SET_PROJECT_ID', () => {
    const projectId = 123;

    it(`should set the projectId  to ${projectId}`, () => {
      mutations[types.SET_PROJECT_ID](state, projectId);
      expect(state.projectId).toBe(projectId);
    });
  });

  describe('SET_PIPELINE_ID', () => {
    const pipelineId = 123;

    it(`should set the pipelineId to ${pipelineId}`, () => {
      mutations[types.SET_PIPELINE_ID](state, pipelineId);
      expect(state.pipelineId).toBe(pipelineId);
    });
  });

  describe('REQUEST_PIPELINE_JOBS', () => {
    it('should set the isLoading to true', () => {
      mutations[types.REQUEST_PIPELINE_JOBS](state);
      expect(state.isLoading).toBe(true);
    });
  });

  describe('RECEIVE_PIPELINE_JOBS_SUCCESS', () => {
    it('should set the isLoading to false and pipelineJobs to the jobs array', () => {
      const jobs = [{}, {}];
      mutations[types.RECEIVE_PIPELINE_JOBS_SUCCESS](state, jobs);
      expect(state.isLoading).toBe(false);
      expect(state.pipelineJobs).toBe(jobs);
    });
  });

  describe('RECEIVE_PIPELINE_JOBS_ERROR', () => {
    it('should set the isLoading to false', () => {
      mutations[types.RECEIVE_PIPELINE_JOBS_ERROR](state);
      expect(state.isLoading).toBe(false);
    });
  });
});
