import Api from '~/api';
import axios from '~/lib/utils/axios_utils';

export default {
  ...Api,
  geoNodesPath: '/api/:version/geo_nodes',
  geoDesignsPath: '/api/:version/geo_replication/designs',
  ldapGroupsPath: '/api/:version/ldap/:provider/groups.json',
  subscriptionPath: '/api/:version/namespaces/:id/gitlab_subscription',
  childEpicPath: '/api/:version/groups/:id/epics/:epic_iid/epics',
  groupEpicsPath:
    '/api/:version/groups/:id/epics?include_ancestor_groups=:includeAncestorGroups&include_descendant_groups=:includeDescendantGroups',
  epicIssuePath: '/api/:version/groups/:id/epics/:epic_iid/issues/:issue_id',
  groupPackagesPath: '/api/:version/groups/:id/packages',
  projectPackagesPath: '/api/:version/projects/:id/packages',
  projectPackagePath: '/api/:version/projects/:id/packages/:package_id',
  cycleAnalyticsTasksByTypePath: '/-/analytics/type_of_work/tasks_by_type',
  cycleAnalyticsSummaryDataPath: '/-/analytics/value_stream_analytics/summary',
  cycleAnalyticsGroupStagesAndEventsPath: '/-/analytics/value_stream_analytics/stages',
  cycleAnalyticsStageEventsPath: '/-/analytics/value_stream_analytics/stages/:stage_id/records',
  cycleAnalyticsStageMedianPath: '/-/analytics/value_stream_analytics/stages/:stage_id/median',
  cycleAnalyticsStagePath: '/-/analytics/value_stream_analytics/stages/:stage_id',
  cycleAnalyticsDurationChartPath:
    '/-/analytics/value_stream_analytics/stages/:stage_id/duration_chart',
  cycleAnalyticsGroupLabelsPath: '/api/:version/groups/:namespace_path/labels',
  codeReviewAnalyticsPath: '/api/:version/analytics/code_review',
  countriesPath: '/-/countries',
  countryStatesPath: '/-/country_states',
  paymentFormPath: '/-/subscriptions/payment_form',
  paymentMethodPath: '/-/subscriptions/payment_method',
  confirmOrderPath: '/-/subscriptions',

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

  groupEpics({ groupId, includeAncestorGroups = false, includeDescendantGroups = true }) {
    const url = Api.buildUrl(this.groupEpicsPath)
      .replace(':id', groupId)
      .replace(':includeAncestorGroups', includeAncestorGroups)
      .replace(':includeDescendantGroups', includeDescendantGroups);

    return axios.get(url);
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

  cycleAnalyticsTasksByType(params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsTasksByTypePath);
    return axios.get(url, { params });
  },

  cycleAnalyticsSummaryData(params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsSummaryDataPath);
    return axios.get(url, { params });
  },

  cycleAnalyticsGroupStagesAndEvents(groupId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsGroupStagesAndEventsPath);

    return axios.get(url, {
      params: { group_id: groupId, ...params },
    });
  },

  cycleAnalyticsStageEvents(groupId, stageId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsStageEventsPath).replace(':stage_id', stageId);
    return axios.get(url, { params: { ...params, group_id: groupId } });
  },

  cycleAnalyticsStageMedian(groupId, stageId, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsStageMedianPath).replace(':stage_id', stageId);
    return axios.get(url, { params: { ...params, group_id: groupId } });
  },

  cycleAnalyticsCreateStage(groupId, data) {
    const url = Api.buildUrl(this.cycleAnalyticsGroupStagesAndEventsPath);

    return axios.post(url, data, {
      params: { group_id: groupId },
    });
  },

  cycleAnalyticsStageUrl(stageId) {
    return Api.buildUrl(this.cycleAnalyticsStagePath).replace(':stage_id', stageId);
  },

  cycleAnalyticsUpdateStage(stageId, groupId, data) {
    const url = this.cycleAnalyticsStageUrl(stageId);

    return axios.put(url, data, {
      params: { group_id: groupId },
    });
  },

  cycleAnalyticsRemoveStage(stageId, groupId) {
    const url = this.cycleAnalyticsStageUrl(stageId);

    return axios.delete(url, {
      params: { group_id: groupId },
    });
  },

  cycleAnalyticsDurationChart(stageSlug, params = {}) {
    const url = Api.buildUrl(this.cycleAnalyticsDurationChartPath).replace(':stage_id', stageSlug);

    return axios.get(url, {
      params,
    });
  },

  cycleAnalyticsGroupLabels(groupId, params = {}) {
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

  getGeoDesigns(params = {}) {
    const url = Api.buildUrl(this.geoDesignsPath);
    return axios.get(url, { params });
  },

  initiateAllGeoDesignSyncs(action) {
    const url = Api.buildUrl(this.geoDesignsPath);
    return axios.post(`${url}/${action}`, {});
  },

  initiateGeoDesignSync({ projectId, action }) {
    const url = Api.buildUrl(this.geoDesignsPath);
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
};
