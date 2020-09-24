import Api from 'ee/api';
import axios from '~/lib/utils/axios_utils';

export default class GeoNodesService {
  constructor() {
    this.geoNodesPath = Api.buildUrl(Api.geoNodesPath);
  }

  getGeoNodes() {
    return axios.get(this.geoNodesPath);
  }

  // eslint-disable-next-line class-methods-use-this
  getGeoNodeDetails(node) {
    return axios.get(node.statusPath);
  }

  // eslint-disable-next-line class-methods-use-this
  toggleNode(node) {
    return axios.put(node.basePath, {
      enabled: !node.enabled, // toggle from existing status
    });
  }

  // eslint-disable-next-line class-methods-use-this
  repairNode(node) {
    return axios.post(node.repairPath);
  }

  // eslint-disable-next-line class-methods-use-this
  removeNode(node) {
    return axios.delete(node.basePath);
  }
}
