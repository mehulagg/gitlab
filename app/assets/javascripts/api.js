import axios from './lib/utils/axios_utils';
import { joinPaths } from './lib/utils/url_utility';
import { deprecatedCreateFlash as flash } from '~/flash';
import { __ } from '~/locale';

const DEFAULT_PER_PAGE = 20;

const Api = {
  groupsPath: '/api/:version/groups.json',
  groupPath: '/api/:version/groups/:id',
  groupMembersPath: '/api/:version/groups/:id/members',
  groupMilestonesPath: '/api/:version/groups/:id/milestones',
  subgroupsPath: '/api/:version/groups/:id/subgroups',
  namespacesPath: '/api/:version/namespaces.json',
  groupPackagesPath: '/api/:version/groups/:id/packages',
  projectPackagesPath: '/api/:version/projects/:id/packages',
  projectPackagePath: '/api/:version/projects/:id/packages/:package_id',
  groupProjectsPath: '/api/:version/groups/:id/projects.json',
  projectsPath: '/api/:version/projects.json',
  projectPath: '/api/:version/projects/:id',
  forkedProjectsPath: '/api/:version/projects/:id/forks',
  projectLabelsPath: '/:namespace_path/:project_path/-/labels',
  projectFileSchemaPath: '/:namespace_path/:project_path/-/schema/:ref/:filename',
  projectUsersPath: '/api/:version/projects/:id/users',
  projectMergeRequestsPath: '/api/:version/projects/:id/merge_requests',
  projectMergeRequestPath: '/api/:version/projects/:id/merge_requests/:mrid',
  projectMergeRequestChangesPath: '/api/:version/projects/:id/merge_requests/:mrid/changes',
  projectMergeRequestVersionsPath: '/api/:version/projects/:id/merge_requests/:mrid/versions',
  projectRunnersPath: '/api/:version/projects/:id/runners',
  projectProtectedBranchesPath: '/api/:version/projects/:id/protected_branches',
  projectSearchPath: '/api/:version/projects/:id/search',
  projectMilestonesPath: '/api/:version/projects/:id/milestones',
  projectIssuePath: '/api/:version/projects/:id/issues/:issue_iid',
  mergeRequestsPath: '/api/:version/merge_requests',
  groupLabelsPath: '/groups/:namespace_path/-/labels',
  issuableTemplatePath: '/:namespace_path/:project_path/templates/:type/:key',
  projectTemplatePath: '/api/:version/projects/:id/templates/:type/:key',
  projectTemplatesPath: '/api/:version/projects/:id/templates/:type',
  userCountsPath: '/api/:version/user_counts',
  usersPath: '/api/:version/users.json',
  userPath: '/api/:version/users/:id',
  userStatusPath: '/api/:version/users/:id/status',
  userProjectsPath: '/api/:version/users/:id/projects',
  userPostStatusPath: '/api/:version/user/status',
  commitPath: '/api/:version/projects/:id/repository/commits/:sha',
  commitsPath: '/api/:version/projects/:id/repository/commits',
  applySuggestionPath: '/api/:version/suggestions/:id/apply',
  applySuggestionBatchPath: '/api/:version/suggestions/batch_apply',
  commitPipelinesPath: '/:project_id/commit/:sha/pipelines',
  branchSinglePath: '/api/:version/projects/:id/repository/branches/:branch',
  createBranchPath: '/api/:version/projects/:id/repository/branches',
  releasesPath: '/api/:version/projects/:id/releases',
  releasePath: '/api/:version/projects/:id/releases/:tag_name',
  releaseLinksPath: '/api/:version/projects/:id/releases/:tag_name/assets/links',
  releaseLinkPath: '/api/:version/projects/:id/releases/:tag_name/assets/links/:link_id',
  mergeRequestsPipeline: '/api/:version/projects/:id/merge_requests/:merge_request_iid/pipelines',
  adminStatisticsPath: '/api/:version/application/statistics',
  pipelineJobsPath: '/api/:version/projects/:id/pipelines/:pipeline_id/jobs',
  pipelineSinglePath: '/api/:version/projects/:id/pipelines/:pipeline_id',
  pipelinesPath: '/api/:version/projects/:id/pipelines/',
  createPipelinePath: '/api/:version/projects/:id/pipeline',
  environmentsPath: '/api/:version/projects/:id/environments',
  contextCommitsPath:
    '/api/:version/projects/:id/merge_requests/:merge_request_iid/context_commits',
  rawFilePath: '/api/:version/projects/:id/repository/files/:path/raw',
  issuePath: '/api/:version/projects/:id/issues/:issue_iid',
  tagsPath: '/api/:version/projects/:id/repository/tags',
  freezePeriodsPath: '/api/:version/projects/:id/freeze_periods',
  usageDataIncrementUniqueUsersPath: '/api/:version/usage_data/increment_unique_users',
  featureFlagUserLists: '/api/:version/projects/:id/feature_flags_user_lists',
  featureFlagUserList: '/api/:version/projects/:id/feature_flags_user_lists/:list_iid',
  billableGroupMembersPath: '/api/:version/groups/:id/billable_members',
  groupSearchPath: '/api/:version/groups/:id/search',

  group(groupId, callback = () => {}) {
    const url = Api.buildUrl(Api.groupPath).replace(':id', groupId);
    return axios.get(url).then(({ data }) => {
      callback(data);

      return data;
    });
  },

  groupPackages(id, options = {}) {
    const url = Api.buildUrl(this.groupPackagesPath).replace(':id', id);
    return axios.get(url, options);
  },

  projectPackages(id, options = {}) {
    const url = Api.buildUrl(this.projectPackagesPath).replace(':id', id);
    return axios.get(url, options);
  },

  buildProjectPackageUrl(projectId, packageId) {
    return Api.buildUrl(this.projectPackagePath)
      .replace(':id', projectId)
      .replace(':package_id', packageId);
  },

  projectPackage(projectId, packageId) {
    const url = this.buildProjectPackageUrl(projectId, packageId);
    return axios.get(url);
  },

  deleteProjectPackage(projectId, packageId) {
    const url = this.buildProjectPackageUrl(projectId, packageId);
    return axios.delete(url);
  },

  groupMembers(id, options) {
    const url = Api.buildUrl(this.groupMembersPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  inviteGroupMember(id, data) {
    const url = Api.buildUrl(this.groupMembersPath).replace(':id', encodeURIComponent(id));

    return axios.post(url, data);
  },

  groupMilestones(id, options) {
    const url = Api.buildUrl(this.groupMilestonesPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  groupSearch(id, options = {}) {
    const url = Api.buildUrl(Api.groupSearchPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        search: options.search,
        scope: options.scope,
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  // Return groups list. Filtered by query
  groups(query, options, callback = () => {}) {
    const url = Api.buildUrl(Api.groupsPath);
    return axios
      .get(url, {
        params: {
          search: query,
          per_page: DEFAULT_PER_PAGE,
          ...options,
        },
      })
      .then(({ data }) => {
        callback(data);

        return data;
      });
  },

  groupLabels(namespace) {
    const url = Api.buildUrl(Api.groupLabelsPath).replace(':namespace_path', namespace);
    return axios.get(url).then(({ data }) => data);
  },

  // Return namespaces list. Filtered by query
  namespaces(query, callback) {
    const url = Api.buildUrl(Api.namespacesPath);
    return axios
      .get(url, {
        params: {
          search: query,
          per_page: DEFAULT_PER_PAGE,
        },
      })
      .then(({ data }) => callback(data));
  },

  // Return projects list. Filtered by query
  projects(query, options, callback = () => {}) {
    const url = Api.buildUrl(Api.projectsPath);
    const defaults = {
      search: query,
      per_page: DEFAULT_PER_PAGE,
      simple: true,
    };

    if (gon.current_user_id) {
      defaults.membership = true;
    }

    return axios
      .get(url, {
        params: Object.assign(defaults, options),
      })
      .then(({ data, headers }) => {
        callback(data);
        return { data, headers };
      });
  },

  projectUsers(projectPath, query = '', options = {}) {
    const url = Api.buildUrl(this.projectUsersPath).replace(':id', encodeURIComponent(projectPath));

    return axios
      .get(url, {
        params: {
          search: query,
          per_page: DEFAULT_PER_PAGE,
          ...options,
        },
      })
      .then(({ data }) => data);
  },

  // Return single project
  project(projectPath) {
    const url = Api.buildUrl(Api.projectPath).replace(':id', encodeURIComponent(projectPath));

    return axios.get(url);
  },

  // Update a single project
  updateProject(projectPath, data) {
    const url = Api.buildUrl(Api.projectPath).replace(':id', encodeURIComponent(projectPath));
    return axios.put(url, data);
  },

  /**
   * Get all projects for a forked relationship to a specified project
   * @param {string} projectPath - Path or ID of a project
   * @param {Object} params - Get request parameters
   * @returns {Promise} - Request promise
   */
  projectForks(projectPath, params) {
    const url = Api.buildUrl(Api.forkedProjectsPath).replace(
      ':id',
      encodeURIComponent(projectPath),
    );

    return axios.get(url, { params });
  },

  /**
   * Get all Merge Requests for a project, eventually filtering based on
   * supplied parameters
   * @param projectPath
   * @param params
   * @returns {Promise}
   */
  projectMergeRequests(projectPath, params = {}) {
    const url = Api.buildUrl(Api.projectMergeRequestsPath).replace(
      ':id',
      encodeURIComponent(projectPath),
    );

    return axios.get(url, { params });
  },

  createProjectMergeRequest(projectPath, options) {
    const url = Api.buildUrl(Api.projectMergeRequestsPath).replace(
      ':id',
      encodeURIComponent(projectPath),
    );

    return axios.post(url, options);
  },

  // Return Merge Request for project
  projectMergeRequest(projectPath, mergeRequestId, params = {}) {
    const url = Api.buildUrl(Api.projectMergeRequestPath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':mrid', mergeRequestId);

    return axios.get(url, { params });
  },

  projectMergeRequestChanges(projectPath, mergeRequestId) {
    const url = Api.buildUrl(Api.projectMergeRequestChangesPath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':mrid', mergeRequestId);

    return axios.get(url);
  },

  projectMergeRequestVersions(projectPath, mergeRequestId) {
    const url = Api.buildUrl(Api.projectMergeRequestVersionsPath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':mrid', mergeRequestId);

    return axios.get(url);
  },

  projectRunners(projectPath, config = {}) {
    const url = Api.buildUrl(Api.projectRunnersPath).replace(
      ':id',
      encodeURIComponent(projectPath),
    );

    return axios.get(url, config);
  },

  projectProtectedBranches(id, query = '') {
    const url = Api.buildUrl(Api.projectProtectedBranchesPath).replace(
      ':id',
      encodeURIComponent(id),
    );

    return axios
      .get(url, {
        params: {
          search: query,
          per_page: DEFAULT_PER_PAGE,
        },
      })
      .then(({ data }) => data);
  },

  projectSearch(id, options = {}) {
    const url = Api.buildUrl(Api.projectSearchPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        search: options.search,
        scope: options.scope,
      },
    });
  },

  projectMilestones(id, params = {}) {
    const url = Api.buildUrl(Api.projectMilestonesPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params,
    });
  },

  addProjectIssueAsTodo(projectId, issueIid) {
    const url = Api.buildUrl(Api.projectIssuePath)
      .replace(':id', encodeURIComponent(projectId))
      .replace(':issue_iid', encodeURIComponent(issueIid));

    return axios.post(`${url}/todo`);
  },

  mergeRequests(params = {}) {
    const url = Api.buildUrl(Api.mergeRequestsPath);

    return axios.get(url, { params });
  },

  newLabel(namespacePath, projectPath, data, callback) {
    let url;

    if (projectPath) {
      url = Api.buildUrl(Api.projectLabelsPath)
        .replace(':namespace_path', namespacePath)
        .replace(':project_path', projectPath);
    } else {
      url = Api.buildUrl(Api.groupLabelsPath).replace(':namespace_path', namespacePath);
    }

    return axios
      .post(url, {
        label: data,
      })
      .then(res => callback(res.data))
      .catch(e => callback(e.response.data));
  },

  // Return group projects list. Filtered by query
  groupProjects(groupId, query, options, callback) {
    const url = Api.buildUrl(Api.groupProjectsPath).replace(':id', groupId);
    const defaults = {
      search: query,
      per_page: DEFAULT_PER_PAGE,
    };
    return axios
      .get(url, {
        params: { ...defaults, ...options },
      })
      .then(({ data }) => callback(data))
      .catch(() => flash(__('Something went wrong while fetching projects')));
  },

  commit(id, sha, params = {}) {
    const url = Api.buildUrl(this.commitPath)
      .replace(':id', encodeURIComponent(id))
      .replace(':sha', encodeURIComponent(sha));

    return axios.get(url, { params });
  },

  commitMultiple(id, data) {
    // see https://docs.gitlab.com/ee/api/commits.html#create-a-commit-with-multiple-files-and-actions
    const url = Api.buildUrl(Api.commitsPath).replace(':id', encodeURIComponent(id));
    return axios.post(url, JSON.stringify(data), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    });
  },

  applySuggestion(id) {
    const url = Api.buildUrl(Api.applySuggestionPath).replace(':id', encodeURIComponent(id));

    return axios.put(url);
  },

  applySuggestionBatch(ids) {
    const url = Api.buildUrl(Api.applySuggestionBatchPath);

    return axios.put(url, { ids });
  },

  commitPipelines(projectId, sha) {
    const encodedProjectId = projectId
      .split('/')
      .map(fragment => encodeURIComponent(fragment))
      .join('/');

    const url = Api.buildUrl(Api.commitPipelinesPath)
      .replace(':project_id', encodedProjectId)
      .replace(':sha', encodeURIComponent(sha));

    return axios.get(url);
  },

  branchSingle(id, branch) {
    const url = Api.buildUrl(Api.branchSinglePath)
      .replace(':id', encodeURIComponent(id))
      .replace(':branch', encodeURIComponent(branch));

    return axios.get(url);
  },

  projectTemplate(id, type, key, options, callback) {
    const url = Api.buildUrl(this.projectTemplatePath)
      .replace(':id', encodeURIComponent(id))
      .replace(':type', type)
      .replace(':key', encodeURIComponent(key));

    return axios.get(url, { params: options }).then(res => {
      if (callback) callback(res.data);

      return res;
    });
  },

  projectTemplates(id, type, params = {}, callback) {
    const url = Api.buildUrl(this.projectTemplatesPath)
      .replace(':id', encodeURIComponent(id))
      .replace(':type', type);

    return axios.get(url, { params }).then(res => {
      if (callback) callback(res.data);

      return res;
    });
  },

  issueTemplate(namespacePath, projectPath, key, type, callback) {
    const url = Api.buildUrl(Api.issuableTemplatePath)
      .replace(':key', encodeURIComponent(key))
      .replace(':type', type)
      .replace(':project_path', projectPath)
      .replace(':namespace_path', namespacePath);
    return axios
      .get(url)
      .then(({ data }) => callback(null, data))
      .catch(callback);
  },

  users(query, options) {
    const url = Api.buildUrl(this.usersPath);
    return axios.get(url, {
      params: {
        search: query,
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  user(id, options) {
    const url = Api.buildUrl(this.userPath).replace(':id', encodeURIComponent(id));
    return axios.get(url, {
      params: options,
    });
  },

  userCounts() {
    const url = Api.buildUrl(this.userCountsPath);
    return axios.get(url);
  },

  userStatus(id, options) {
    const url = Api.buildUrl(this.userStatusPath).replace(':id', encodeURIComponent(id));
    return axios.get(url, {
      params: options,
    });
  },

  userProjects(userId, query, options, callback) {
    const url = Api.buildUrl(Api.userProjectsPath).replace(':id', userId);
    const defaults = {
      search: query,
      per_page: DEFAULT_PER_PAGE,
    };
    return axios
      .get(url, {
        params: { ...defaults, ...options },
      })
      .then(({ data }) => callback(data))
      .catch(() => flash(__('Something went wrong while fetching projects')));
  },

  branches(id, query = '', options = {}) {
    const url = Api.buildUrl(this.createBranchPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        search: query,
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  createBranch(id, { ref, branch }) {
    const url = Api.buildUrl(this.createBranchPath).replace(':id', encodeURIComponent(id));

    return axios.post(url, {
      ref,
      branch,
    });
  },

  postUserStatus({ emoji, message }) {
    const url = Api.buildUrl(this.userPostStatusPath);

    return axios.put(url, {
      emoji,
      message,
    });
  },

  postMergeRequestPipeline(id, { mergeRequestId }) {
    const url = Api.buildUrl(this.mergeRequestsPipeline)
      .replace(':id', encodeURIComponent(id))
      .replace(':merge_request_iid', mergeRequestId);

    return axios.post(url);
  },

  releases(id, options = {}) {
    const url = Api.buildUrl(this.releasesPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  release(projectPath, tagName) {
    const url = Api.buildUrl(this.releasePath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':tag_name', encodeURIComponent(tagName));

    return axios.get(url);
  },

  createRelease(projectPath, release) {
    const url = Api.buildUrl(this.releasesPath).replace(':id', encodeURIComponent(projectPath));

    return axios.post(url, release);
  },

  updateRelease(projectPath, tagName, release) {
    const url = Api.buildUrl(this.releasePath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':tag_name', encodeURIComponent(tagName));

    return axios.put(url, release);
  },

  createReleaseLink(projectPath, tagName, link) {
    const url = Api.buildUrl(this.releaseLinksPath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':tag_name', encodeURIComponent(tagName));

    return axios.post(url, link);
  },

  deleteReleaseLink(projectPath, tagName, linkId) {
    const url = Api.buildUrl(this.releaseLinkPath)
      .replace(':id', encodeURIComponent(projectPath))
      .replace(':tag_name', encodeURIComponent(tagName))
      .replace(':link_id', encodeURIComponent(linkId));

    return axios.delete(url);
  },

  adminStatistics() {
    const url = Api.buildUrl(this.adminStatisticsPath);
    return axios.get(url);
  },

  pipelineSingle(id, pipelineId) {
    const url = Api.buildUrl(this.pipelineSinglePath)
      .replace(':id', encodeURIComponent(id))
      .replace(':pipeline_id', encodeURIComponent(pipelineId));

    return axios.get(url);
  },

  pipelineJobs(projectId, pipelineId) {
    const url = Api.buildUrl(this.pipelineJobsPath)
      .replace(':id', encodeURIComponent(projectId))
      .replace(':pipeline_id', encodeURIComponent(pipelineId));

    return axios.get(url);
  },

  // Return all pipelines for a project or filter by query params
  pipelines(id, options = {}) {
    const url = Api.buildUrl(this.pipelinesPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: options,
    });
  },

  createPipeline(id, data) {
    const url = Api.buildUrl(this.createPipelinePath).replace(':id', encodeURIComponent(id));

    return axios.post(url, data, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
  },

  environments(id) {
    const url = Api.buildUrl(this.environmentsPath).replace(':id', encodeURIComponent(id));
    return axios.get(url);
  },

  createContextCommits(id, mergeRequestIid, data) {
    const url = Api.buildUrl(this.contextCommitsPath)
      .replace(':id', encodeURIComponent(id))
      .replace(':merge_request_iid', mergeRequestIid);

    return axios.post(url, data);
  },

  allContextCommits(id, mergeRequestIid) {
    const url = Api.buildUrl(this.contextCommitsPath)
      .replace(':id', encodeURIComponent(id))
      .replace(':merge_request_iid', mergeRequestIid);

    return axios.get(url);
  },

  removeContextCommits(id, mergeRequestIid, data) {
    const url = Api.buildUrl(this.contextCommitsPath)
      .replace(':id', id)
      .replace(':merge_request_iid', mergeRequestIid);

    return axios.delete(url, { data });
  },

  getRawFile(id, path, params = { ref: 'master' }) {
    const url = Api.buildUrl(this.rawFilePath)
      .replace(':id', encodeURIComponent(id))
      .replace(':path', encodeURIComponent(path));

    return axios.get(url, { params });
  },

  updateIssue(project, issue, data = {}) {
    const url = Api.buildUrl(Api.issuePath)
      .replace(':id', encodeURIComponent(project))
      .replace(':issue_iid', encodeURIComponent(issue));

    return axios.put(url, data);
  },

  updateMergeRequest(project, mergeRequest, data = {}) {
    const url = Api.buildUrl(Api.projectMergeRequestPath)
      .replace(':id', encodeURIComponent(project))
      .replace(':mrid', encodeURIComponent(mergeRequest));

    return axios.put(url, data);
  },

  tags(id, query = '', options = {}) {
    const url = Api.buildUrl(this.tagsPath).replace(':id', encodeURIComponent(id));

    return axios.get(url, {
      params: {
        search: query,
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    });
  },

  freezePeriods(id) {
    const url = Api.buildUrl(this.freezePeriodsPath).replace(':id', encodeURIComponent(id));

    return axios.get(url);
  },

  createFreezePeriod(id, freezePeriod = {}) {
    const url = Api.buildUrl(this.freezePeriodsPath).replace(':id', encodeURIComponent(id));

    return axios.post(url, freezePeriod);
  },

  trackRedisHllUserEvent(event) {
    if (!gon.features?.usageDataApi) {
      return null;
    }

    const url = Api.buildUrl(this.usageDataIncrementUniqueUsersPath);
    const headers = {
      'Content-Type': 'application/json',
    };

    return axios.post(url, { event }, { headers });
  },

  buildUrl(url) {
    return joinPaths(gon.relative_url_root || '', url.replace(':version', gon.api_version));
  },

  fetchFeatureFlagUserLists(id, page) {
    const url = Api.buildUrl(this.featureFlagUserLists).replace(':id', id);

    return axios.get(url, { params: { page } });
  },

  createFeatureFlagUserList(id, list) {
    const url = Api.buildUrl(this.featureFlagUserLists).replace(':id', id);

    return axios.post(url, list);
  },

  fetchFeatureFlagUserList(id, listIid) {
    const url = Api.buildUrl(this.featureFlagUserList)
      .replace(':id', id)
      .replace(':list_iid', listIid);

    return axios.get(url);
  },

  updateFeatureFlagUserList(id, list) {
    const url = Api.buildUrl(this.featureFlagUserList)
      .replace(':id', id)
      .replace(':list_iid', list.iid);

    return axios.put(url, list);
  },

  deleteFeatureFlagUserList(id, listIid) {
    const url = Api.buildUrl(this.featureFlagUserList)
      .replace(':id', id)
      .replace(':list_iid', listIid);

    return axios.delete(url);
  },

  fetchBillableGroupMembersList(namespaceId, options = {}, callback = () => {}) {
    const url = Api.buildUrl(this.billableGroupMembersPath).replace(':id', namespaceId);
    const defaults = {
      per_page: DEFAULT_PER_PAGE,
      page: 1,
    };

    return axios
      .get(url, {
        params: {
          ...defaults,
          ...options,
        },
      })
      .then(({ data, headers }) => {
        callback(data);
        return { data, headers };
      });
  },
};

export default Api;
