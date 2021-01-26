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
    <!-- <div class="form-group dropdown compare-form-group to js-compare-to-dropdown"> -->
    <div class="form-group js-compare-to-dropdown">
      <div class="input-group inline-input-group gl-display-flex!">
        <span class="input-group-prepend">
          <div class="input-group-text">
            {{ s__('CompareBranches|Source') }}
          </div>
        </span>
        <branch-dropdown
          :refs-project-path="refsProjectPath"
          params="from"
          :params-branch="paramsFrom"
        />
      </div>
    </div>
    <div class="compare-ellipsis inline">...</div>
    <!-- <div class="form-group dropdown compare-form-group from js-compare-from-dropdown"> -->
    <div class="form-group js-compare-from-dropdown">
      <div class="input-group inline-input-group gl-display-flex!">
        <span class="input-group-prepend">
          <div class="input-group-text">
            {{ s__('CompareBranches|Target') }}
          </div>
        </span>
        <branch-dropdown
          :refs-project-path="refsProjectPath"
          params="to"
          :params-branch="paramsTo"
        />
      </div>
    </div>
    &nbsp;
    <gl-button category="primary" variant="success" type="submit">
      {{ s__('CompareBranches|Compare') }}
    </gl-button>
  </form>
</template>
