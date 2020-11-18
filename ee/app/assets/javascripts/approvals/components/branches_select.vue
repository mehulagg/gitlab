<script>
import $ from 'jquery';
import 'select2/select2';
import { debounce } from 'lodash';
import Api from 'ee/api';
import { loadCSSFile } from '~/lib/utils/css_utils';
import { __ } from '~/locale';

const anyBranch = {
  id: null,
  name: __('Any branch'),
};

function formatSelection(object) {
  return `<span>${object.name}</span>`;
}
function formatResult(result) {
  const isAnyBranch = result.id ? `monospace` : '';

  return `
    <span class="result-name ${isAnyBranch}">${result.name}</span>
  `;
}

export default {
  props: {
    projectId: {
      type: String,
      required: true,
    },
    initRule: {
      type: Object,
      required: false,
      default: null,
    },
    isInvalid: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  watch: {
    value(val) {
      if (val.length > 0) {
        this.clear();
      }
    },
    isInvalid(val) {
      const $container = this.$input.select2('container');

      $container.toggleClass('is-invalid', val);
    },
  },
  mounted() {
    const $modal = $('#project-settings-approvals-create-modal .modal-content');
    this.$input = $(this.$refs.input);

    loadCSSFile(gon.select2_css_path)
      .then(() => {
        this.$input
          .select2({
            minimumInputLength: 0,
            multiple: false,
            closeOnSelect: false,
            formatResult,
            formatSelection,
            initSelection: (element, callback) => this.initialOption(element, callback),
            query: debounce(({ term, callback }) => {
              // eslint-disable-next-line promise/no-nesting
              this.fetchBranches(term)
                .then(callback)
                .catch(() => {});
            }, 250),
            id: ({ type, id }) => `${type}${id}`,
          })
          .on('change', e => this.onChange(e))
          .on('select2-open', () => {
            // https://stackoverflow.com/questions/18487056/select2-doesnt-work-when-embedded-in-a-bootstrap-modal
            // Ensure search feature works in modal
            // (known issue with our current select2 version, solved in version 4 with "dropdownParent")
            $modal.removeAttr('tabindex', '-1');
          })
          .on('select2-close', () => {
            $modal.attr('tabindex', '-1');
          });
      })
      .catch(() => {});
  },
  beforeDestroy() {
    this.$input.select2('destroy');
  },
  methods: {
    fetchBranches(term) {
      const excludeAnyBranch = term && !term.toLowerCase().includes('any');
      return Api.projectProtectedBranches(this.projectId, term).then(results => ({
        results: excludeAnyBranch ? results : [anyBranch, ...results],
      }));
    },
    initialOption(element, callback) {
      let currentBranch = anyBranch;

      if (this.initRule?.protectedBranches.length) {
        const { name, id } = this.initRule.protectedBranches[0];
        if (id) {
          currentBranch = { name, id };
          this.selectedId = id;
        }
      }

      return callback(currentBranch);
    },
    onChange() {
      const value = this.$input.select2('data');
      this.$emit('input', value.id);
    },
    clear() {
      this.$input.select2('data', []);
    },
  },
};
</script>

<template>
  <input ref="input" name="protected_branch_ids" type="hidden" />
</template>
