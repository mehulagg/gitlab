import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import * as ProjectsApi from '~/api/projects_api';
import httpStatus from '~/lib/utils/http_status';

describe('ProjectsApi', () => {
  const dummyApiVersion = 'v3000';
  const dummyUrlRoot = '/gitlab';
  const dummyGon = {
    api_version: dummyApiVersion,
    relative_url_root: dummyUrlRoot,
  };
  let originalGon;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    originalGon = window.gon;
    window.gon = { ...dummyGon };
  });

  afterEach(() => {
    mock.restore();
    window.gon = originalGon;
  });

  describe('projects', () => {
    it('fetches projects with membership when logged in', (done) => {
      const query = 'dummy query';
      const options = { unused: 'option' };
      const expectedUrl = `${dummyUrlRoot}/api/${dummyApiVersion}/projects.json`;
      window.gon.current_user_id = 1;
      mock.onGet(expectedUrl).reply(httpStatus.OK, [
        {
          name: 'test',
        },
      ]);

      ProjectsApi.getProjects(query, options, (response) => {
        expect(response.length).toBe(1);
        expect(response[0].name).toBe('test');
        done();
      });
    });

    it('fetches projects without membership when not logged in', (done) => {
      const query = 'dummy query';
      const options = { unused: 'option' };
      const expectedUrl = `${dummyUrlRoot}/api/${dummyApiVersion}/projects.json`;
      mock.onGet(expectedUrl).reply(httpStatus.OK, [
        {
          name: 'test',
        },
      ]);

      ProjectsApi.getProjects(query, options, (response) => {
        expect(response.length).toBe(1);
        expect(response[0].name).toBe('test');
        done();
      });
    });
  });

  describe('getRawFile', () => {
    const dummyProjectPath = 'gitlab-org/gitlab';
    const dummyFilePath = 'doc/CONTRIBUTING.md';
    const expectedUrl = `${dummyUrlRoot}/api/${dummyApiVersion}/projects/${encodeURIComponent(
      dummyProjectPath,
    )}/repository/files/${encodeURIComponent(dummyFilePath)}/raw`;

    describe('when the raw file is successfully fetched', () => {
      it('resolves the Promise', () => {
        mock.onGet(expectedUrl).replyOnce(httpStatus.OK);

        return ProjectsApi.getRawFile(dummyProjectPath, dummyFilePath).then(() => {
          expect(mock.history.get).toHaveLength(1);
        });
      });
    });

    describe('when an error occurs while getting a raw file', () => {
      it('rejects the Promise', () => {
        mock.onPost(expectedUrl).replyOnce(httpStatus.INTERNAL_SERVER_ERROR);

        return ProjectsApi.getRawFile(dummyProjectPath, dummyFilePath).catch(() => {
          expect(mock.history.get).toHaveLength(1);
        });
      });
    });
  });
});
