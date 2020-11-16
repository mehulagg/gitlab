<script>
import { GlButton } from '@gitlab/ui';
import { isExperimentEnabled } from '~/lib/utils/experimentation';
import { s__ } from '~/locale';
import Tracking from '~/tracking';

export default {
  name: 'PipelinesEmptyState',
  components: {
    GlButton,
  },
  props: {
    helpPagePath: {
      type: String,
      required: true,
    },
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    canSetCi: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    infoMessage() {
      if (isExperimentEnabled('pipelinesEmptyState')) {
        return s__(`Pipelines|GitLab CI/CD can automatically build,
          test, and deploy your code. Let GitLab take care of time
          consuming tasks, so you can spend more time creating.`);
      }

      return s__(`Pipelines|Continuous Integration can help
        catch bugs by running your tests automatically,
        while Continuous Deployment can help you deliver
        code to your product environment.`);
    },
    buttonMessage() {
      if (isExperimentEnabled('pipelinesEmptyState')) {
        return s__('Pipelines|Get started with CI/CD');
      }

      return s__('Pipelines|Get started with Pipelines');
    },
  },
  mounted() {
    this.track('viewed');
  },
  methods: {
    track(action) {
      if (!gon.tracking_data) {
        return;
      }

      Tracking.event(gon.tracking_data.category, action, gon.tracking_data);
    },
  },
};
</script>
<template>
  <div class="row empty-state js-empty-state">
    <div class="col-12">
      <div class="svg-content svg-250"><img :src="emptyStateSvgPath" /></div>
    </div>

    <div class="col-12">
      <div class="text-content">
        <template v-if="canSetCi">
          <h4 data-testid="header-text" class="text-center">
            {{ s__('Pipelines|Build with confidence') }}
          </h4>
          <p data-testid="info-text">{{ infoMessage }}</p>

          <div class="text-center">
            <gl-button
              :href="helpPagePath"
              variant="info"
              category="primary"
              data-testid="get-started-pipelines"
              @click="track('documentation_clicked')"
            >
              {{ buttonMessage }}
            </gl-button>
          </div>
        </template>

        <p v-else class="text-center">
          {{ s__('Pipelines|This project is not currently set up to run pipelines.') }}
        </p>
      </div>
    </div>
  </div>
</template>
