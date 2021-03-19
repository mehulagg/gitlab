<script>
/* eslint-disable no-unused-vars */
import $ from 'jquery';
import select2 from 'select2/select2';
import { loadCSSFile } from '~/lib/utils/css_utils';

export default {
  name: 'AddLicenseFormDropdown',
  props: {
    placeholder: {
      type: String,
      required: false,
      default: '',
    },
    value: {
      type: String,
      required: false,
      default: '',
    },
    knownLicenses: {
      type: Array,
      required: true,
    },
  },
  mounted() {
    loadCSSFile(gon.select2_css_path)
      .then(() => {
        $(this.$refs.dropdownInput)
          .val(this.value)
          .select2({
            allowClear: true,
            placeholder: this.placeholder,
            createSearchChoice: (term) => ({ id: term, text: term }),
            createSearchChoicePosition: 'bottom',
            data: this.knownLicenses.map((license) => ({
              id: license,
              text: license,
            })),
          })
          .on('change', (e) => {
            this.$emit('input', e.target.value);
          });
      })
      .catch(() => {});
  },
  beforeDestroy() {
    $(this.$refs.dropdownInput).select2('destroy');
  },
};
</script>
<template>
  <input ref="dropdownInput" type="hidden" />
</template>
