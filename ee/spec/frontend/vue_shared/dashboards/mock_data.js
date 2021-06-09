import { TEST_HOST } from 'spec/test_constants';
import { differenceInMilliseconds } from '~/lib/utils/datetime_utility';

const AVATAR_URL = `${TEST_HOST}/dummy.jpg`;

export const mockText = {
  ADD_PROJECTS_ERROR: 'Something went wrong, unable to add projects to dashboard',
  REMOVE_PROJECT_ERROR: 'Something went wrong, unable to delete project',
  NO_SEARCH_RESULTS: 'Sorry, no projects matched your search',
  RECEIVE_PROJECTS_ERROR: 'Something went wrong, unable to get projects',
};

export const mockHeaders = {
  pageInfo: {
    currentPage: 1,
    nextPage: 2,
    totalResults: 33,
    totalPages: 2,
  },
};

export function mockPipelineData(
  status = 'success',
  id = 1,
  finishedTimeStamp = new Date(differenceInMilliseconds(86400000)).toISOString(),
  isTag = false,
) {
  return {
    id,
    user: {
      id: 1,
      name: 'Test',
      username: 'test',
      state: 'active',
      avatar_url: AVATAR_URL,
      web_url: '/test',
      status_tooltip_html: null,
      path: '/test',
    },
    active: false,
    path: '/test/test-project/-/pipelines/1',
    details: {
      status: {
        icon: `status_${status}`,
        text: status,
        label: status,
        group: status,
        tooltip: status,
        has_details: true,
        details_path: '/test/test-project/-/pipelines/1',
        illustration: null,
      },
      finished_at: finishedTimeStamp,
    },
    ref: {
      name: 'main',
      path: 'test/test-project/commits/main',
      tag: isTag,
      branch: true,
      merge_request: false,
    },
    commit: {
      id: 'e778416d94deaf75bdabcc8fdd6b7d21f482bcca',
      short_id: 'e778416d',
      title: "Add new file to the branch I'm working on",
      message: "Add new file to the branch I'm working on",
      author: {
        id: 1,
        name: 'Test',
        username: 'test',
        state: 'active',
        avatar_url: AVATAR_URL,
        status_tooltip_html: null,
        path: '/test',
      },
      commit_url: '/test/test-project/commit/e778416d94deaf75bdabcc8fdd6b7d21f482bcca',
      commit_path: '/test/test-project/commit/e778416d94deaf75bdabcc8fdd6b7d21f482bcca',
    },
    project: {
      full_name: 'Test / test-project',
      full_path: '/test/test-project',
      name: 'test-project',
    },
  };
}

export function mockProjectData(
  projectCount = 1,
  currentPipelineStatus = 'success',
  upstreamStatus = 'success',
  alertCount = 0,
) {
  return Array(projectCount)
    .fill(null)
    .map((_, index) => ({
      id: index,
      description: '',
      name: 'test-project',
      name_with_namespace: 'Test / test-project',
      path: 'test-project',
      path_with_namespace: 'test/test-project',
      created_at: '2019-02-01T15:40:27.522Z',
      default_branch: 'main',
      tag_list: [],
      topics: [],
      avatar_url: null,
      web_url: 'https://mock-web_url/',
      namespace: {
        id: 1,
        name: 'test',
        path: 'test',
        kind: 'user',
        full_path: 'user',
        parent_id: null,
      },
      remove_path: '/-/operations?project_id=1',
      last_pipeline: mockPipelineData(currentPipelineStatus),
      upstream_pipeline: mockPipelineData(upstreamStatus),
      downstream_pipelines: [],
      alert_count: alertCount,
      upgrade_required: false,
      upgrade_path: '/groups/test/-/billings',
    }));
}
