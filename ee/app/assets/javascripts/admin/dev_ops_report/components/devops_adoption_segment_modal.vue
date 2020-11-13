<script>
import {
  GlFormGroup,
  GlFormInput,
  GlFormCheckboxTree,
  GlModal,
  GlModalDirective,
  GlSprintf,
} from '@gitlab/ui';
// import createSegmentMutation from '../graphql/mutations/create_segment.mutation.graphql';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from '../constants';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
    GlFormCheckboxTree,
    GlSprintf,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    segmentId: {
      type: String,
      required: false,
      default: null,
    },
  },
  i18n: DEVOPS_ADOPTION_STRINGS.modal,
  data() {
    return {
      // Will fetch these guys on modal open, I want to fetch the information every time the modal opens in order to prevent stale data
      // If there's a segment ID we can then fetch those IDs too and built a loaded state for editng
      groups: [
        {
          id: '123',
          full_name: 'Group 1',
        },
        {
          id: '234',
          full_name: 'Group 2',
        },
      ],
      name: '',
      checkboxValues: [],
    };
  },
  computed: {
    isCreateDisabled() {
      return false;
    },
    checkboxOptions() {
      return this.groups.map(({ id, full_name }) => ({ label: full_name, value: id }));
    },
  },
  methods: {
    createSegment() {
      // this.$apollo.mutate({
      //   mutation: createSegmentMutation,
      //   variables: {
      //     name: this.name,
      //     groupIds: this.checkboxValues,
      //   },
      // });
    },
  },
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
};
</script>
<template>
  <div>
    <gl-modal
      :modal-id="$options.devopsSegmentModalId"
      :title="$options.i18n.title"
      :ok-title="$options.i18n.button"
      ok-variant="info"
      size="sm"
      @ok="createSegment"
    >
      <gl-form-group :label="$options.i18n.nameLabel" label-for="name">
        <gl-form-input
          id="name"
          v-model="name"
          type="text"
          :placeholder="$options.i18n.namePlaceholder"
          :required="true"
        />
      </gl-form-group>
      <gl-form-group class="gl-mb-0">
        <gl-form-checkbox-tree
          v-model="checkboxValues"
          :options="checkboxOptions"
          class="gl-p-3 gl-pb-0 gl-mb-2 gl-border-1 gl-border-solid gl-border-gray-100 gl-rounded-base"
        />
        <div class="gl-text-gray-400">
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
  </div>
</template>
