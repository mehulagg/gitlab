<script>
import { GlIcon } from '@gitlab/ui';
import { isNumber } from 'lodash';
import { n__ } from '~/locale';
import { numberToHumanSize, changeInPercent } from '../../lib/utils/number_utils';
import { isNotDiffable } from '../utils/diff_file';

export default {
  components: { GlIcon },
  props: {
    diffFile: {
      type: Object,
      required: false,
      default: () => null,
    },
    addedLines: {
      type: Number,
      required: true,
    },
    removedLines: {
      type: Number,
      required: true,
    },
    diffFilesCountText: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    diffFilesLength() {
      return parseInt(this.diffFilesCountText, 10);
    },
    filesText() {
      return n__('file', 'files', this.diffFilesLength);
    },
    isCompareVersionsHeader() {
      return Boolean(this.diffFilesCountText);
    },
    hasDiffFiles() {
      return isNumber(this.diffFilesLength) && this.diffFilesLength >= 0;
    },
    notDiffable() {
      return this.diffFile ? isNotDiffable(this.diffFile) : false;
    },
    bytes() {
      const computes = {};
      let color = '';
      let sign = '';
      let percent = 0;
      let diff = 0;

      if (this.diffFile) {
        percent = changeInPercent(this.diffFile.old_size, this.diffFile.new_size);
        diff = this.diffFile.new_size - this.diffFile.old_size;
        sign = diff >= 0 ? '+' : '';

        if (diff > 0) {
          color = 'cgreen';
        } else if (diff < 0) {
          color = 'cred';
        }
      }

      computes.text = `${sign}${numberToHumanSize(diff)} (${sign}${percent}%)`;
      computes.percent = percent;
      computes.changed = diff;
      computes.color = color;
      computes.sign = sign;

      return computes;
    },
  },
};
</script>

<template>
  <div
    class="diff-stats"
    :class="{
      'is-compare-versions-header d-none d-lg-inline-flex': isCompareVersionsHeader,
      'd-none d-sm-inline-flex': !isCompareVersionsHeader,
    }"
  >
    <div v-if="notDiffable" :class="bytes.color">
      {{ bytes.text }}
    </div>
    <div v-else class="diff-stats-contents">
      <div v-if="hasDiffFiles" class="diff-stats-group">
        <gl-icon name="doc-code" class="diff-stats-icon text-secondary" />
        <span class="text-secondary bold">{{ diffFilesCountText }} {{ filesText }}</span>
      </div>
      <div
        class="diff-stats-group cgreen d-flex align-items-center"
        :class="{ bold: isCompareVersionsHeader }"
      >
        <span>+</span>
        <span class="js-file-addition-line">{{ addedLines }}</span>
      </div>
      <div
        class="diff-stats-group cred d-flex align-items-center"
        :class="{ bold: isCompareVersionsHeader }"
      >
        <span>-</span>
        <span class="js-file-deletion-line">{{ removedLines }}</span>
      </div>
    </div>
  </div>
</template>
