<script>
import {
  GlAlert,
  GlModal,
  GlModalDirective,
  GlFormInput,
  GlFormSelect,
  GlButton,
  GlSprintf,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { deprecatedCreateFlash as Flash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';

export default {
  components: {
    GlFormSelect,
  },
  directives: {
    SafeHtml,
  },
  props: {
    confirmPhrase: {
      type: String,
      required: true,
    },
    formPath: {
      type: String,
      required: true,
    },
    namespaceOptions: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      selectedNamespace: null,
    };
  },
};
</script>
<template>
  <div>
    <gl-form-select v-model="selectedNamespace" v-safe-html="namespaceOptions" />
  </div>
</template>
