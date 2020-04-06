import Api from '~/api';
import axios from '~/lib/utils/axios_utils';

export default {
  ...Api,
  geoNodesPath: '/api/:version/geo_nodes',
  geoReplicationPath: '/api/:version/geo_replication/:replicable',
  ldapGroupsPath: '/api/:version/ldap/:provider/groups.json',
  subscriptionPath: '/api/:version/namespaces/:id/gitlab_subscription',
  childEpicPath: '/api/:version/groups/:id/epics/:epic_iid/epics',
  groupEpicsPath: '/api/:version/groups/:id/epics',
  epicIssuePath: '/api/:version/groups/:id/epics/:epic_iid/issues/:issue_id',
  groupPackagesPath: '/api/:version/groups/:id/packages',
  projectPackagesPath: '/api/:version/projects/:id/packages',
  projectPackagePath: '/api/:version/projects/:id/packages/:package_id',
  cycleAnalyticsTasksByTypePath: '/groups/:id/-/analytics/type_of_work/tasks_by_type',
  cycleAnalyticsTopLabelsPath: '/groups/:id/-/analytics/type_of_work/tasks_by_type/top_labels',
  cycleAnalyticsSummaryDataPath: '/groups/:id/-/analytics/value_stream_analytics/summary',
  cycleAnalyticsGroupStagesAndEventsPath: '/groups/:id/-/analytics/value_stream_analytics/stages',
  cycleAnalyticsStageEventsPath:
    '/groups/:id/-/analytics/value_stream_analytics/stages/:stage_id/records',
  cycleAnalyticsStageMedianPath:
    '/groups/:id/-/analytics/value_stream_analytics/stages/:stage_id/median',
  cycleAnalyticsStagePath: '/groups/:id/-/analytics/value_stream_analytics/stages/:stage_id',
  cycleAnalyticsDurationChartPath:
    '/groups/:id/-/analytics/value_stream_analytics/stages/:stage_id/duration_chart',
  cycleAnalyticsGroupLabelsPath: '/groups/:namespace_path/-/labels.json',
  codeReviewAnalyticsPath: '/api/:version/analytics/code_review',
  groupActivityIssuesPath: '/api/:version/analytics/group_activity/issues_count',
  groupActivityMergeRequestsPath: '/api/:version/analytics/group_activity/merge_requests_count',
  countriesPath: '/-/countries',
  countryStatesPath: '/-/country_states',
  paymentFormPath: '/-/subscriptions/payment_form',
  paymentMethodPath: '/-/subscriptions/payment_method',
  confirmOrderPath: '/-/subscriptions',
  vulnerabilitiesActionPath: '/api/:version/vulnerabilities/:id/:action',

  userSubscription(namespaceId) {
    const url = Api.buildUrl(this.subscriptionPath).replace(':id', encodeURIComponent(namespaceId));

    return axios.get(url);
  },

  ldapGroups(query, provider, callback) {
    const url = Api.buildUrl(this.ldapGroupsPath).replace(':provider', provider);
    return axios
      .get(url, {
        params: {
          search: query,
          per_page: 20,
          active: true,
        },
      })
      .then(({ data }) => {
        callback(data);

        return data;
      });
  },

  createChildEpic({ groupId, parentEpicIid, title }) {
    const url = Api.buildUrl(this.childEpicPath)
      .replace(':id', encodeURIComponent(groupId))
      .replace(':epic_iid', parentEpicIid);

    return axios.post(url, {
      title,
    });
  },

  groupEpics({
    groupId,
    includeAncestorGroups = false,
    includeDescendantGroups = true,
    search = '',
  }) {
    const url = Api.buildUrl(this.groupEpicsPath).replace(':id', groupId);
    const params = {
      include_ancestor_groups: includeAncestorGroups,
      include_descendant_groups: includeDescendantGroups,
    };

    if (search) {
      params.search = search;
    }

    return axios.get(url, {
      params,
    });
  },

  addEpicIssue({ groupId, epicIid, issueId }) {
    const url = Api.buildUrl(this.epicIssuePath)
      .replace(':id', groupId)
      .replace(':epic_iid', epicIid)
      .replace(':issue_id', issueId);

    return axios.post(url);
  },

  removeEpicIssue({ groupId, epicIid, epicIssueId }) {
    const url = Api.buildUrl(this.epicIssuePath)
      .replace(':id', groupId)
      .replace(':epic_iid', epicIid)
      .replace(':issue_id', epicIssueId);

    return axios.delete(url);
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

  cycleAnalyticsTasksByType(groupId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsTasksByTypePath).replace(':id', groupId);

    return axios.get(url, { params });
  },

  cycleAnalyticsTopLabels(groupId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsTopLabelsPath).replace(':id', groupId);

    return axios.get(url, { params });
  },

  cycleAnalyticsSummaryData(groupId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsSummaryDataPath).replace(':id', groupId);

    return axios.get(url, { params });
  },

  cycleAnalyticsGroupStagesAndEvents(groupId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsGroupStagesAndEventsPath).replace(':id', groupId);

    return axios.get(url, { params });
  },

  cycleAnalyticsStageEvents(groupId, stageId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsStageEventsPath)
      .replace(':id', groupId)
      .replace(':stage_id', stageId);

    return axios.get(url, { params });
  },

  cycleAnalyticsStageMedian(groupId, stageId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsStageMedianPath)
      .replace(':id', groupId)
      .replace(':stage_id', stageId);

    return axios.get(url, { params: { ...params } });
  },

  cycleAnalyticsCreateStage(groupId, data) {
    const url = Api.buildUrl(this.cycleAnalyticsGroupStagesAndEventsPath).replace(':id', groupId);

    return axios.post(url, data);
  },

  cycleAnalyticsStageUrl(stageId, groupId) {
    return Api.buildUrl(this.cycleAnalyticsStagePath)
      .replace(':id', groupId)
      .replace(':stage_id', stageId);
  },

  cycleAnalyticsUpdateStage(stageId, groupId, data) {
    const url = this.cycleAnalyticsStageUrl(stageId, groupId);

    return axios.put(url, data);
  },

  cycleAnalyticsRemoveStage(stageId, groupId) {
    const url = this.cycleAnalyticsStageUrl(stageId, groupId);

    return axios.delete(url);
  },

  cycleAnalyticsDurationChart(groupId, stageSlug, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsDurationChartPath)
      .replace(':id', groupId)
      .replace(':stage_id', stageSlug);

    return axios.get(url, {
      params,
    });
  },

  cycleAnalyticsGroupLabels(groupId, params = { search: null }) {
    // TODO: This can be removed when we resolve the labels endpoint
    // https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25746
    const url = Api.buildUrl(this.cycleAnalyticsGroupLabelsPath).replace(
      ':namespace_path',
      groupId,
    );

    return axios.get(url, {
      params,
    });
  },

  codeReviewAnalytics(params = {}) {
    const url = Api.buildUrl(this.codeReviewAnalyticsPath);
    return axios.get(url, { params });
  },

  groupActivityMergeRequestsCount(groupPath) {
    const url = Api.buildUrl(this.groupActivityMergeRequestsPath);
    return axios.get(url, { params: { group_path: groupPath } });
  },

  groupActivityIssuesCount(groupPath) {
    const url = Api.buildUrl(this.groupActivityIssuesPath);
    return axios.get(url, { params: { group_path: groupPath } });
  },

  getGeoReplicableItems(replicable, params = {}) {
    const url = Api.buildUrl(this.geoReplicationPath).replace(':replicable', replicable);
    return axios.get(url, { params });
  },

  initiateAllGeoReplicableSyncs(replicable, action) {
    const url = Api.buildUrl(this.geoReplicationPath).replace(':replicable', replicable);
    return axios.post(`${url}/${action}`, {});
  },

  initiateGeoReplicableSync(replicable, { projectId, action }) {
    const url = Api.buildUrl(this.geoReplicationPath).replace(':replicable', replicable);
    return axios.put(`${url}/${projectId}/${action}`, {});
  },

  fetchCountries() {
    const url = Api.buildUrl(this.countriesPath);
    return axios.get(url);
  },

  fetchStates(country) {
    const url = Api.buildUrl(this.countryStatesPath);
    return axios.get(url, { params: { country } });
  },

  fetchPaymentFormParams(id) {
    const url = Api.buildUrl(this.paymentFormPath);
    return axios.get(url, { params: { id } });
  },

  fetchPaymentMethodDetails(id) {
    const url = Api.buildUrl(this.paymentMethodPath);
    return axios.get(url, { params: { id } });
  },

  confirmOrder(params = {}) {
    const url = Api.buildUrl(this.confirmOrderPath);
    return axios.post(url, params);
  },

  changeVulnerabilityState(id, state) {
    const url = Api.buildUrl(this.vulnerabilitiesActionPath)
      .replace(':id', id)
      .replace(':action', state);

    return axios.post(url);
  },

  createGeoNode(node) {
    const url = Api.buildUrl(this.geoNodesPath);
    return axios.post(url, node);
  },

  updateGeoNode(node) {
    const url = Api.buildUrl(this.geoNodesPath);
    return axios.put(`${url}/${node.id}`, node);
  },
};
