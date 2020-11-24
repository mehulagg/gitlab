import { pickBy } from 'lodash';
import { SUPPORTED_FILTER_PARAMETERS } from './constants';

export const validateParams = params => {
  return pickBy(params, (val, key) => SUPPORTED_FILTER_PARAMETERS.includes(key) && val);
};

// TODO: REMOVE THIS SINCE API NOW GUARANTEE UNIQUE JOBS
export const createUniqueJobId = (stageName, jobName) => `${stageName}-${jobName}`;

/**
 * This function takes a json payload that comes from a yml
 * file converted to json through `jsyaml` library. Because we
 * naively convert the entire yaml to json, some keys (like `includes`)
 * are irrelevant to rendering the graph and must be removed. We also
 * restructure the data to have the structure from an API response for the
 * pipeline data.
 * @param {Object} jsonData
 * @returns {Array} - Array of stages containing all jobs
 */
export const preparePipelineGraphData = jsonData => {
  const jsonKeys = Object.keys(jsonData);
  const jobNames = jsonKeys.filter(job => jsonData[job]?.stage);
  // Creates an object with only the valid jobs
  const jobs = jsonKeys.reduce((acc, val) => {
    if (jobNames.includes(val)) {
      return {
        ...acc,
        [val]: { ...jsonData[val], id: createUniqueJobId(jsonData[val].stage, val) },
      };
    }
    return { ...acc };
  }, {});

  // We merge both the stages from the "stages" key in the yaml and the stage associated
  // with each job to show the user both the stages they explicitly defined, and those
  // that they added under jobs. We also remove duplicates.
  const jobStages = jobNames.map(job => jsonData[job].stage);
  const userDefinedStages = jsonData?.stages ?? [];

  // The order is important here. We always show the stages in order they were
  // defined in the `stages` key first, and then stages that are under the jobs.
  const stages = Array.from(new Set([...userDefinedStages, ...jobStages]));

  const arrayOfJobsByStage = stages.map(val => {
    return jobNames.filter(job => {
      return jsonData[job].stage === val;
    });
  });

  console.log(jobs);

  const pipelineData = stages.map((stage, index) => {
    const stageJobs = arrayOfJobsByStage[index];
    return {
      name: stage,
      groups: stageJobs.map(job => {
        return {
          name: job,
          jobs: [{ ...jsonData[job] }],
          id: createUniqueJobId(stage, job),
        };
      }),
    };
  });

  return { stages: pipelineData, jobs };
};

export const createJobsHash = ({ stages }) => {
  const jobs = {};

  stages.forEach(stage => {
    stage.groups.forEach(group => {
      group.jobs.forEach(job => {
        // Flatten the needs to only keep an array of names
        const needs = job.needs.map(need => need.name);
        jobs[job.name] = { ...job, needs, id: createUniqueJobId(stage.name, job.name) };
      });
    });
  });

  return jobs;
};

/**
 * This function takes the stages array and transform it
 * into a hash where each key is a job and value is an array
 * that stores all of its needs. This used to build the links
 * between jobs.
 * @param {Array} stages
 * @returns {Object} - Hash of jobs and needs
 */
export const generateJobNeedsDict = jobs => {
  const arrOfJobNames = Object.keys(jobs);

  return arrOfJobNames.reduce((acc, value) => {
    const recursiveNeeds = jobName => {
      if (!jobs[jobName]?.needs) {
        return [];
      }

      return jobs[jobName].needs
        .map(job => {
          const { id } = jobs[job];
          // If we already have the needs of a job in the accumulator,
          // then we use the memoized data instead of the recursive call
          // to save some performance.
          const newNeeds = acc[id] ?? recursiveNeeds(job);

          return [id, ...newNeeds];
        })
        .flat(Infinity);
    };

    // To ensure we don't have duplicates job relationship when 2 jobs
    // needed by another both depends on the same jobs, we remove any
    // duplicates from the array.
    const uniqueValues = Array.from(new Set(recursiveNeeds(value)));

    return { ...acc, [jobs[value].id]: uniqueValues };
  }, {});
};
