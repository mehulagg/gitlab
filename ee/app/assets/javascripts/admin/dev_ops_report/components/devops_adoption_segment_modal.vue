<script>
import { GlFormGroup, GlFormInput, GlFormCheckboxTree, GlModal, GlSprintf } from '@gitlab/ui';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from '../constants';

export default {
  name: 'DevopsAdoptionSegmentModal',
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormCheckboxTree,
    GlSprintf,
  },
  props: {
    segmentId: {
      type: String,
      required: false,
      default: null,
    },
    groups: {
      type: Array,
      required: true,
    },
  },
  i18n: DEVOPS_ADOPTION_STRINGS.modal,
  data() {
    return {
      name: '',
      checkboxValues: [],
    };
  },
  computed: {
    checkboxOptions() {
      return this.groups.map(({ id, full_name }) => ({ label: full_name, value: id }));
    },
  },
  methods: {
    createSegment() {},
  },
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
};
</script>
<template>
  <gl-modal
    :modal-id="$options.devopsSegmentModalId"
    :title="$options.i18n.title"
    :ok-title="$options.i18n.button"
    ok-variant="info"
    size="sm"
    scrollable
    @ok="createSegment"
  >
    <gl-form-group :label="$options.i18n.nameLabel" label-for="name" data-testid="name">
      <gl-form-input
        id="name"
        v-model="name"
        type="text"
        :placeholder="$options.i18n.namePlaceholder"
        :required="true"
      />
    </gl-form-group>
    <gl-form-group class="gl-mb-0" data-testid="groups">
      <gl-form-checkbox-tree
        v-model="checkboxValues"
        :options="checkboxOptions"
        :hide-toggle-all="true"
        class="gl-p-3 gl-pb-0 gl-mb-2 gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base"
      />
      <div class="gl-text-gray-400" data-testid="groupsHelperText">
        <gl-sprintf
          :message="
            n__(
              $options.i18n.selectedGroupsTextSingular,
              $options.i18n.selectedGroupsTextPlural,
              checkboxValues.length,
            )
          "
        >
          <template #selectedCount>
            {{ checkboxValues.length }}
          </template>
        </gl-sprintf>
      </div>
    </gl-form-group>
  </gl-modal>
</template>
