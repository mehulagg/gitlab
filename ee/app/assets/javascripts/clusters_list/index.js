import Vue from 'vue';
import VueApollo from 'vue-apollo';
import loadAgents from './load_agents';
import loadClusters from '~/clusters_list/load_clusters';

Vue.use(VueApollo);

export default () => {
  loadClusters(Vue);
  loadAgents(Vue, VueApollo);
};
