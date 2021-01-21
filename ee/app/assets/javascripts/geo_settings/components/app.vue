<script>
import { mapActions, mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import GeoSettingsForm from './geo_settings_form.vue';

export default {
  name: 'GeoSettingsApp',
  components: {
    GlLoadingIcon,
    GeoSettingsForm,
  },
  computed: {
    ...mapState(['isLoading']),
  },
  created() {
    this.fetchGeoSettings();
  },
  methods: {
    ...mapActions(['fetchGeoSettings']),
  },
};
</script>

<template>
  <article data-testid="geoSettingsContainer">
    <h3 class="page-title">{{ __('Geo Settings') }}</h3>
    <p>
      {{
        __(
          'Set the timeout in seconds to send a secondary node status to the primary and IPs allowed for the secondary nodes.',
        )
      }}
    </p>
    <gl-loading-icon v-if="isLoading" size="xl" />
    <geo-settings-form v-else />
  </article>
</template>
