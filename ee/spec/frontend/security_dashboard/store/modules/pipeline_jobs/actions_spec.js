import MockAdapter from 'axios-mock-adapter';
import * as actions from 'ee/security_dashboard/store/modules/pipeline_jobs/actions';
import * as types from 'ee/security_dashboard/store/modules/pipeline_jobs/mutation_types';
import createState from 'ee/security_dashboard/store/modules/pipeline_jobs/state';
import testAction from 'helpers/vuex_action_helper';
import { TEST_HOST } from 'spec/test_constants';

import axios from '~/lib/utils/axios_utils';

describe('pipeling jobs actions', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('setPipelineJobsPath', () => {
    const pipelineJobsPath = 123;

    it('should commit the SET_PIPELINE_JOBS_PATH mutation', done => {
      testAction(
        actions.setPipelineJobsPath,
        pipelineJobsPath,
        state,
        [
          {
            type: types.SET_PIPELINE_JOBS_PATH,
            payload: pipelineJobsPath,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setProjectId', () => {
    const projectId = 123;

    it('should commit the SET_PIPELINE_JOBS_PATH mutation', done => {
      testAction(
        actions.setProjectId,
        projectId,
        state,
        [
          {
            type: types.SET_PROJECT_ID,
            payload: projectId,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setPipelineId', () => {
    const pipelineId = 123;

    it('should commit the SET_PIPELINE_ID mutation', done => {
      testAction(
        actions.setPipelineId,
        pipelineId,
        state,
        [
          {
            type: types.SET_PIPELINE_ID,
            payload: pipelineId,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('fetchPipelineJobs', () => {
    let mock;
    const jobs = [{}, {}];

    beforeEach(() => {
      state.pipelineJobsPath = `${TEST_HOST}/pipelines/jobs.json`;
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.restore();
    });

    describe('on success with pipeline path', () => {
      beforeEach(() => {
        mock.onGet(state.pipelineJobsPath).replyOnce(200, jobs);
      });

      it('should commit the request and success mutations', done => {
        testAction(
          actions.fetchPipelineJobs,
          {},
          state,
          [
            { type: types.REQUEST_PIPELINE_JOBS },
            {
              type: types.RECEIVE_PIPELINE_JOBS_SUCCESS,
              payload: jobs,
            },
          ],
          [],
          done,
        );
      });
    });

    describe('on success with pipeline id and project id', () => {
      beforeEach(() => {
        mock.onGet('/api/undefined/projects/123/pipelines/321/jobs').replyOnce(200, jobs);
      });

      it('should commit the request and success mutations', done => {
        state.pipelineJobsPath = '';
        state.projectId = 123;
        state.pipelineId = 321;

        testAction(
          actions.fetchPipelineJobs,
          {},
          state,
          [
            { type: types.REQUEST_PIPELINE_JOBS },
            {
              type: types.RECEIVE_PIPELINE_JOBS_SUCCESS,
              payload: jobs,
            },
          ],
          [],
          done,
        );
      });
    });

    describe('without pipelineJobsPath set', () => {
      beforeEach(() => {
        mock.onGet(state.pipelineJobsPath).replyOnce(200, jobs);
      });

      it('should commit RECEIVE_PIPELINE_JOBS_ERROR mutation', done => {
        state.pipelineJobsPath = '';

        testAction(
          actions.fetchPipelineJobs,
          {},
          state,
          [
            {
              type: types.RECEIVE_PIPELINE_JOBS_ERROR,
            },
          ],
          [],
          done,
        );
      });
    });

    describe('without projectId or pipelineId set', () => {
      beforeEach(() => {
        mock.onGet(state.pipelineJobsPath).replyOnce(200, jobs);
      });

      it('should commit RECEIVE_PIPELINE_JOBS_ERROR mutation', done => {
        state.pipelineJobsPath = '';
        state.projectId = undefined;
        state.pipelineId = undefined;

        testAction(
          actions.fetchPipelineJobs,
          {},
          state,
          [
            {
              type: types.RECEIVE_PIPELINE_JOBS_ERROR,
            },
          ],
          [],
          done,
        );
      });
    });

    describe('with server error', () => {
      beforeEach(() => {
        mock.onGet(state.pipelineJobsPath).replyOnce(404);
      });

      it('should commit REQUEST_PIPELINE_JOBS and RECEIVE_PIPELINE_JOBS_ERROR mutation', done => {
        testAction(
          actions.fetchPipelineJobs,
          {},
          state,
          [
            { type: types.REQUEST_PIPELINE_JOBS },
            {
              type: types.RECEIVE_PIPELINE_JOBS_ERROR,
            },
          ],
          [],
          done,
        );
      });
    });
  });
});
