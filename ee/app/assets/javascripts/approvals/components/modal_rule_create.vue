<script>
import { mapState } from 'vuex';
import { __ } from '~/locale';
import GlModalVuex from '~/vue_shared/components/gl_modal_vuex.vue';
import RuleForm from './rule_form.vue';

export default {
  components: {
    GlModalVuex,
    RuleForm,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
    isMrEdit: {
      type: Boolean,
      default: true,
      required: false,
    },
  },
  computed: {
    ...mapState('createModal', {
      rule: 'data',
    }),
    title() {
      return !this.rule || this.defaultRuleName
        ? __('Add approval rule')
        : __('Update approval rule');
    },
    defaultRuleName() {
      return this.rule?.defaultRuleName;
    },
  },
  methods: {
    submit() {
      this.$refs.form.submit();
    },
  },
};
</script>

<template>
  <gl-modal-vuex
    modal-module="createModal"
    :modal-id="modalId"
    :title="title"
    :ok-title="title"
    ok-variant="success"
    :cancel-title="__('Cancel')"
    size="sm"
    @ok.prevent="submit"
  >
    <rule-form
      ref="form"
      :init-rule="rule"
      :is-mr-edit="isMrEdit"
      :default-rule-name="defaultRuleName"
    />
  </gl-modal-vuex>
</template>
