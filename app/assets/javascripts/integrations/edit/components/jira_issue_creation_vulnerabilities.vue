<script>
import { GlFormCheckbox } from '@gitlab/ui';

export default {
  components: {
    GlFormCheckbox,
  },
};
</script>

<template>
  <div>
    <gl-form-checkbox>
      {{ s__('JiraService|Enable Jira issues creation from vulnerabilities') }}
      <template #help>
        {{
          s__(
            'JiraService|Issues created from vulnerabilities in this project will be Jira issues, even if GitLab issues are enabled.',
          )
        }}
      </template>
    </gl-form-checkbox>
  </div>
</template>
