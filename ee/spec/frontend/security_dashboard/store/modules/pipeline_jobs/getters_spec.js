// import createState from 'ee/security_dashboard/store/modules/pipeline_jobs/state';
import { FUZZING_STAGE } from 'ee/security_dashboard/store/modules/pipeline_jobs/constants';
import * as getters from 'ee/security_dashboard/store/modules/pipeline_jobs/getters';

describe('pipeline jobs module getters', () => {
  describe('hasFuzzingArtifacts', () => {
    it('should return true when the pipeline has at least one fuzzing job with at least one artifact', () => {
      const pipelineJobs = [{ stage: FUZZING_STAGE, artifacts: [{}] }];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(true);
    });

    it('should return true when the pipeline has many jobs and at least one fuzzing job with at least one artifact', () => {
      const pipelineJobs = [
        { stage: 'other', artifacts: [] },
        { stage: FUZZING_STAGE, artifacts: [{}] },
      ];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(true);
    });

    it('should return false when the pipeline has a fuzzing job with 0 artifacts', () => {
      const pipelineJobs = [{ stage: FUZZING_STAGE, artifacts: [] }];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(false);
    });

    it('should return false when the pipeline has no fuzzing job with 0 artifacts', () => {
      const pipelineJobs = [{ stage: 'other', artifacts: [] }];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(false);
    });

    it('should return false when the pipeline has no fuzzing job with 1 artifacts', () => {
      const pipelineJobs = [{ stage: 'other', artifacts: [{}] }];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(false);
    });

    it('should return false when the pipeline has many jobs and at least one fuzzing job with no fuzzing artifact', () => {
      const pipelineJobs = [
        { stage: 'other', artifacts: [] },
        { stage: FUZZING_STAGE, artifacts: [] },
      ];
      const state = { pipelineJobs };

      const result = getters.hasFuzzingArtifacts(state);
      expect(result).toBe(false);
    });
  });

  describe('fuzzingJobsWithArtifact', () => {
    it('should return a fuzzing job when the pipeline has at least one fuzzing job with at least one artifact', () => {
      const pipelineJobs = [{ stage: FUZZING_STAGE, artifacts: [{}] }];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual(pipelineJobs);
    });

    it('should return a fuzzing job when the pipeline has many jobs and at least one fuzzing job with at least one artifact', () => {
      const pipelineJobs = [
        { stage: 'other', artifacts: [] },
        { stage: FUZZING_STAGE, artifacts: [{}] },
      ];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual([pipelineJobs[1]]);
    });

    it('should not return a fuzzing job when the pipeline has a fuzzing job with 0 artifacts', () => {
      const pipelineJobs = [{ stage: FUZZING_STAGE, artifacts: [] }];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual([]);
    });

    it('should not return a fuzzing job when the pipeline has no fuzzing job with 0 artifacts', () => {
      const pipelineJobs = [{ stage: 'other', artifacts: [] }];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual([]);
    });

    it('should not return a fuzzing job when the pipeline has no fuzzing job with 1 artifacts', () => {
      const pipelineJobs = [{ stage: 'other', artifacts: [{}] }];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual([]);
    });

    it('should not return a fuzzing job when the pipeline has many jobs and at least one fuzzing job with no fuzzing artifact', () => {
      const pipelineJobs = [
        { stage: 'other', artifacts: [] },
        { stage: FUZZING_STAGE, artifacts: [] },
      ];
      const state = { pipelineJobs };

      const result = getters.fuzzingJobsWithArtifact(state);
      expect(result).toEqual([]);
    });
  });
});
