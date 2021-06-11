<script>
import { GlButton, GlDropdown, GlDropdownItem, GlDropdownDivider, GlSprintf } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { slugifyWithUnderscore } from '~/lib/utils/text_utility';
import Tracking from '~/tracking';
import { I18N } from '../constants';
import { generateInitialStageData } from './create_value_stream_form/utils';
import DeleteValueStreamModal from './delete_value_stream_modal.vue';
import ValueStreamForm from './value_stream_form.vue';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlSprintf,
    ValueStreamForm,
    DeleteValueStreamModal,
  },
  mixins: [Tracking.mixin()],
  data() {
    return {
      showCreateModal: false,
      showDeleteModal: false,
      isEditing: false,
      initialData: {
        name: '',
        stages: [],
      },
    };
  },
  computed: {
    ...mapState({
      data: 'valueStreams',
      selectedValueStream: 'selectedValueStream',
      selectedValueStreamStages: 'stages',
      initialFormErrors: 'createValueStreamErrors',
      defaultStageConfig: 'defaultStageConfig',
    }),
    hasValueStreams() {
      return Boolean(this.data.length);
    },
    selectedValueStreamName() {
      return this.selectedValueStream?.name || '';
    },
    selectedValueStreamId() {
      return this.selectedValueStream?.id || null;
    },
    isCustomValueStream() {
      return this.selectedValueStream?.isCustom || false;
    },
  },
  methods: {
    ...mapActions(['setSelectedValueStream']),
    onSuccess(message) {
      this.$toast.show(message, { position: 'top-center' });
    },
    isSelected(id) {
      return Boolean(this.selectedValueStreamId && this.selectedValueStreamId === id);
    },
    onSelect(selectedId) {
      this.setSelectedValueStream(this.data.find(({ id }) => id === selectedId));
    },
    onCreate() {
      this.showCreateModal = true;
      this.isEditing = false;
      this.initialData = {
        name: '',
        stages: [],
      };
    },
    onEdit() {
      this.showCreateModal = true;
      this.isEditing = true;
      this.initialData = {
        ...this.selectedValueStream,
        stages: generateInitialStageData(this.defaultStageConfig, this.selectedValueStreamStages),
      };
    },
    slugify(valueStreamTitle) {
      return slugifyWithUnderscore(valueStreamTitle);
    },
  },
  I18N,
};
</script>
<template>
  <div>
    <gl-button
      v-if="isCustomValueStream"
      data-testid="edit-value-stream"
      data-track-action="click_button"
      data-track-label="edit_value_stream_form_open"
      @click="onEdit"
      >{{ $options.I18N.EDIT_VALUE_STREAM }}</gl-button
    >
    <gl-dropdown
      v-if="hasValueStreams"
      data-testid="dropdown-value-streams"
      :text="selectedValueStreamName"
      right
    >
      <gl-dropdown-item
        v-for="{ id, name: streamName } in data"
        :key="id"
        :is-check-item="true"
        :is-checked="isSelected(id)"
        data-track-action="click_dropdown"
        :data-track-label="slugify(streamName)"
        @click="onSelect(id)"
        >{{ streamName }}</gl-dropdown-item
      >
      <gl-dropdown-divider />
      <gl-dropdown-item
        data-testid="create-value-stream"
        data-track-action="click_dropdown"
        data-track-label="create_value_stream_form_open"
        @click="onCreate"
        >{{ $options.I18N.CREATE_VALUE_STREAM }}</gl-dropdown-item
      >
      <gl-dropdown-item
        v-if="isCustomValueStream"
        variant="danger"
        data-testid="delete-value-stream"
        data-track-action="click_dropdown"
        data-track-label="delete_value_stream_form_open"
        @click="showDeleteModal = true"
      >
        <gl-sprintf :message="$options.I18N.DELETE_NAME">
          <template #name>{{ selectedValueStreamName }}</template>
        </gl-sprintf>
      </gl-dropdown-item>
    </gl-dropdown>
    <gl-button
      v-else
      data-testid="create-value-stream-button"
      data-track-action="click_button"
      data-track-label="create_value_stream_form_open"
      @click="onCreate"
      >{{ $options.I18N.CREATE_VALUE_STREAM }}</gl-button
    >
    <value-stream-form
      :initial-data="initialData"
      :initial-form-errors="initialFormErrors"
      :default-stage-config="defaultStageConfig"
      :is-editing="isEditing"
      :is-visible="showCreateModal"
      @hidden="showCreateModal = false"
      @success="onSuccess"
    />
    <delete-value-stream-modal
      v-if="selectedValueStream"
      :selected-value-stream="selectedValueStream"
      :is-visible="showDeleteModal"
      @hidden="showDeleteModal = false"
      @success="onSuccess"
    />
  </div>
</template>
