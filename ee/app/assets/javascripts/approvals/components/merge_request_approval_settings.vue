<script>
import { mapActions, mapState } from 'vuex';
import {
  GlButton,
  GlFormGroup,
  GlFormCheckbox,
} from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlFormGroup,
    GlFormCheckbox,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
      default: '',
    },
  },
  computed: {
    ...mapState({
      allowAuthorApproval: (state) => state.approvals.allowAuthorApproval,
      isLoading: (state) => state.approvals.isLoading,
    }),
    preventAuthorApproval() {
      return !this.allowAuthorApproval;
    },
  },
  mounted() {
    this.fetchSetting(this.endpoint);
  },
  methods: {
    ...mapActions(['fetchSetting']),
  },
  i18n: {
    authorApprovalLabel: s__('Prevent MR approvals by the author.'),
    saveChanges: s__('Save changes'),
  },
}
</script>


<template>
  <div class="form-group">
    <gl-form-group>
      <gl-form-checkbox v-model="preventAuthorApproval">
        {{ $options.i18n.authorApprovalLabel }}
      </gl-form-checkbox>
      <gl-button
        type="submit"
        variant="success"
        category="primary"
        class="gl-mt-6"
      >
        {{ $options.i18n.saveChanges }}
      </gl-button>
    </gl-form-group>
  </div>
</template>
