import Vue from 'vue';
import VueApollo from 'vue-apollo';
import loadAgents from 'ee_else_ce/clusters_list/load_agents';
import loadClusters from './load_clusters';

Vue.use(VueApollo);

export default () => {
  loadClusters(Vue);
  loadAgents(Vue, VueApollo);
};
