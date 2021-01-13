<script>
import { GlButtonGroup, GlButton, GlTooltipDirective, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import CurrentDayIndicator from './current_day_indicator.vue';
import RotationAssignee from '../../rotations/components/rotation_assignee.vue';
import DeleteRotationModal from '../../rotations/components/delete_rotation_modal.vue';
import { editRotationModalId, deleteRotationModalId } from '../../../constants';

export const i18n = {
  editRotationLabel: s__('OnCallSchedules|Edit rotation'),
  deleteRotationLabel: s__('OnCallSchedules|Delete rotation'),
};

export default {
  i18n,
  editRotationModalId,
  deleteRotationModalId,
  components: {
    GlButtonGroup,
    GlButton,
    CurrentDayIndicator,
    RotationAssignee,
    DeleteRotationModal,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotations: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      rotationToUpdate: {},
    };
  },
  methods: {
    setRotationToUpdate(rotation) {
      this.rotationToUpdate = rotation;
    },
  },
};
</script>

<template>
  <div class="list-section">
    <div
      v-for="rotation in rotations"
      :key="rotation.id"
      class="list-item list-item-empty clearfix"
    >
      <span
        class="details-cell gl-display-flex gl-justify-content-space-between gl-align-items-center gl-pl-3"
      >
        <span class="gl-str-truncated">{{ rotation.name }}</span>
        <gl-button-group class="gl-px-2">
          <gl-button
            v-gl-modal="$options.editRotationModalId"
            v-gl-tooltip
            category="tertiary"
            :title="$options.i18n.editRotationLabel"
            icon="pencil"
            :aria-label="$options.i18n.editRotationLabel"
          />
          <gl-button
            v-gl-modal="$options.deleteRotationModalId"
            v-gl-tooltip
            category="tertiary"
            :title="$options.i18n.deleteRotationLabel"
            icon="remove"
            :aria-label="$options.i18n.deleteRotationLabel"
            @click="setRotationToUpdate(rotation)"
          />
        </gl-button-group>
      </span>
      <span
        v-for="(timeframeItem, index) in timeframe"
        :key="index"
        class="timeline-cell"
        data-testid="timelineCell"
      >
        <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
        <rotation-assignee
          :assignee="rotation.participants.nodes[index]"
          :assignee-index="index"
          :rotation-length="rotation.length"
          :rotation-starts-at="rotation.startsAt"
        />
      </span>
    </div>
    <delete-rotation-modal
      :rotation="rotationToUpdate"
      :modal-id="$options.deleteRotationModalId"
      @set-rotation-to-update="setRotationToUpdate"
    />
  </div>
</template>
