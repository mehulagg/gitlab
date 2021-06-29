<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import DagNew from '../dag/dag_new.vue';
import PipelineGraph from './pipeline_graph.vue';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    PipelineGraph,
    DagNew,
  },
  props: {
    ciConfigData: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      currentGraph: 'Pipeline',
    };
  },
  computed: {
    isPipelineGraph() {
      return this.currentGraph === 'Pipeline';
    },
    isDagGraph() {
      return this.currentGraph === 'DAG';
    },
  },
  methods: {
    setCurrentGraph(val) {
      this.currentGraph = val;
    },
  },
};
</script>
<template>
  <div>
    <gl-dropdown :text="currentGraph">
      <gl-dropdown-item @click="setCurrentGraph('Pipeline')">Pipeline</gl-dropdown-item>
      <gl-dropdown-item @click="setCurrentGraph('DAG')">DAG</gl-dropdown-item>
    </gl-dropdown>
    <pipeline-graph v-if="isPipelineGraph" :pipeline-data="ciConfigData" />
    <dag-new v-if="isDagGraph" :graph-data="ciConfigData" />
  </div>
</template>
