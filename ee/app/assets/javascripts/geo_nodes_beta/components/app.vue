<script>
import { GlSprintf, GlLink, GlButton } from '@gitlab/ui';

export default {
  name: 'GeoNodesBetaApp',
    components: {
    GlSprintf,
    GlLink,
    GlButton,
  },
  props: {
    geoInformationPath: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <section>
    <h3>{{ __("Geo sites") }}</h3>
    <div class="gl-display-flex gl-align-items-center">
      <gl-sprintf
        :message="
          s__(
            'Geo|With GitLab Geo, you can install a special read-only and replicated instance anywhere. %{linkStart}More Information%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <gl-link class="gl-ml-2" :href="geoInformationPath" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
      <gl-button class="gl-ml-auto" variant="success">{{ __("New site") }}</gl-button>
    </div>
  </section>
</template>
