import { pickBy } from 'lodash';
import { SUPPORTED_FILTER_PARAMETERS } from './constants';
import { createNodeDict } from './components/parsing_utils';

export const validateParams = (params) => {
  return pickBy(params, (val, key) => SUPPORTED_FILTER_PARAMETERS.includes(key) && val);
};

export const createUniqueLinkId = (stageName, jobName) => `${stageName}-${jobName}`;

/**
 * This function takes the stages array and transform it
 * into a hash where each key is a job name and the job data
 * is associated to that key.
 * @param {Array} stages
 * @returns {Object} - Hash of jobs
 */
export const createJobsHash = (stages = []) => {
  const nodes = stages.flatMap(({ groups }) => groups);
  return createNodeDict(nodes);
};

/**
 * This function takes the jobs hash generated by
 * `createJobsHash` function and returns an easier
 * structure to work with for needs relationship
 * where the key is the job name and the value is an
 * array of all the needs this job has recursively
 * (includes the needs of the needs)
 * @param {Object} jobs
 * @returns {Object} - Hash of jobs and array of needs
 */
export const generateJobNeedsDict = (jobs = {}) => {
  const arrOfJobNames = Object.keys(jobs);

  return arrOfJobNames.reduce((acc, value) => {
    const recursiveNeeds = (jobName) => {
      if (!jobs[jobName]?.needs) {
        return [];
      }

      return jobs[jobName].needs
        .map((job) => {
          // If we already have the needs of a job in the accumulator,
          // then we use the memoized data instead of the recursive call
          // to save some performance.
          const newNeeds = acc[job] ?? recursiveNeeds(job);

          // In case it's a parallel job (size > 1), the name of the group
          // and the job will be different. This mean we also need to add the group name
          // to the list of `needs` to ensure we can properly reference it.
          const group = jobs[job];
          if (group.size > 1) {
            return [job, group.name, ...newNeeds];
          }

          return [job, ...newNeeds];
        })
        .flat(Infinity);
    };

    // To ensure we don't have duplicates job relationship when 2 jobs
    // needed by another both depends on the same jobs, we remove any
    // duplicates from the array.
    const uniqueValues = Array.from(new Set(recursiveNeeds(value)));

    return { ...acc, [value]: uniqueValues };
  }, {});
};
