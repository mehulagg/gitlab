<script>
import { GlCard, GlButton, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import WeeksHeaderItem from './preset_weeks/weeks_header_item.vue';
import AddRotationModal from '../../rotations/add_rotation_modal.vue';

export const i18n = {
  rotationTitle: s__('OnCallSchedules|Rotations'),
  addARotation: s__('OnCallSchedules|Add a rotation'),
};

export default {
  i18n,
  components: {
    GlButton,
    GlCard,
    WeeksHeaderItem,
    AddRotationModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-card header-class="gl-bg-transparent">
      <template #header>
        <div class="gl-display-flex gl-justify-content-space-between">
          <h6 class="gl-m-0">{{ $options.i18n.rotationTitle }}</h6>
          <gl-button v-gl-modal="'create-schedule-rotation-modal'" variant="link">{{
            $options.i18n.addARotation
          }}</gl-button>
        </div>
      </template>

      <div class="timeline-section clearfix">
        <span class="timeline-header-blank"></span>
        <weeks-header-item
          v-for="(timeframeItem, index) in timeframe"
          :key="index"
          :timeframe-index="index"
          :timeframe-item="timeframeItem"
          :timeframe="timeframe"
        />
      </div>
    </gl-card>
    <add-rotation-modal />
  </div>
</template>
