import { FUZZING_STAGE } from './constants';

export const hasFuzzingArtifacts = state => {
  return state.pipelineJobs.some(job => {
    return job.stage === FUZZING_STAGE && job.artifacts.length > 0;
  });
};

export const fuzzingJobsWithArtifact = state => {
  return state.pipelineJobs.filter(job => {
    return job.stage === FUZZING_STAGE && job.artifacts.length > 0;
  });
};
