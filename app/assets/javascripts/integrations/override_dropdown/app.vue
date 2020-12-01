<script>
import { mapState, mapActions, mapGetters } from 'vuex';

import OverrideDropdown from '../edit/components/override_dropdown.vue';

export default {
  name: 'IntegrationForm',
  components: {
    OverrideDropdown,
  },
  computed: {
    ...mapGetters(['propsSource']),
    ...mapState(['defaultState', 'override']),
  },
  methods: {
    ...mapActions(['setOverride']),
  },
};
</script>

<template>
  <override-dropdown
    v-if="defaultState !== null"
    :inherit-from-id="defaultState.id"
    :override="override"
    :learn-more-path="propsSource.learnMorePath"
    @change="setOverride"
  />
</template>
