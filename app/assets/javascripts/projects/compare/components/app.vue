<script>
import { GlButton } from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import BranchDropdown from './branch_dropdown.vue';

export default {
  csrf,
  components: {
    BranchDropdown,
    GlButton,
  },
  props: {
    projectCompareIndexPath: {
      type: String,
      required: true,
    },
    refsProjectPath: {
      type: String,
      required: true,
    },
    paramsFrom: {
      type: String,
      required: true,
    },
    paramsTo: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <form
    class="form-inline js-requires-input js-signature-container"
    method="POST"
    :action="projectCompareIndexPath"
  >
    <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
    <branch-dropdown
      :refs-project-path="refsProjectPath"
      revision-text="Source"
      params="to"
      :params-branch="paramsTo"
    />
    <div class="compare-ellipsis inline">...</div>
    <branch-dropdown
      :refs-project-path="refsProjectPath"
      revision-text="Target"
      params="from"
      :params-branch="paramsFrom"
    />
    &nbsp;
    <gl-button category="primary" variant="success" type="submit">
      {{ s__('CompareBranches|Compare') }}
    </gl-button>
  </form>
</template>
