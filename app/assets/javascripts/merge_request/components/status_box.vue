<script>
import Vue from 'vue';
import { GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import { fetchPolicies } from '~/lib/graphql';

export const data = Vue.observable({
  state: '',
});

export const methods = Vue.observable({
  updateStatus: null,
});

const CLASSES = {
  opened: 'status-box-open',
  closed: 'status-box-mr-closed',
  merged: 'status-box-mr-merged',
};

const STATUS = {
  opened: [__('Open'), 'issue-open-m'],
  closed: [__('Closed'), 'close'],
  merged: [__('Merged'), 'git-merge'],
};

export default {
  components: {
    GlIcon,
  },
  props: {
    initialState: {
      type: String,
      required: true,
    },
  },
  inject: ['query', 'projectPath', 'iid'],
  data() {
    data.state = this.initialState;

    return data;
  },
  computed: {
    statusBoxClass() {
      return CLASSES[this.state];
    },
    statusHumanName() {
      return STATUS[this.state][0];
    },
    statusIconName() {
      return STATUS[this.state][1];
    },
  },
  created() {
    methods.updateStatus = this.fetchState;
  },
  beforeDestroy() {
    methods.updateStatus = null;
  },
  methods: {
    async fetchState() {
      const res = await this.$apollo.query({
        query: this.query,
        variables: {
          projectPath: this.projectPath,
          iid: this.iid,
        },
        fetchPolicy: fetchPolicies.NO_CACHE,
      });

      data.state = res.data.project.issuable.state;
    },
  },
};
</script>

<template>
  <div :class="statusBoxClass" class="issuable-status-box status-box">
    <gl-icon
      :name="statusIconName"
      class="gl-display-block gl-display-sm-none!"
      data-testid="status-icon"
    />
    <span class="gl-display-none gl-display-sm-block">
      {{ statusHumanName }}
    </span>
  </div>
</template>
