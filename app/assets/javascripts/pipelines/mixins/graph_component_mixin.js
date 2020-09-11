import { escape } from 'lodash';

export default {
  methods: {
    capitalizeStageName(name) {
      const escapedName = escape(name);
      return escapedName.charAt(0).toUpperCase() + escapedName.slice(1);
    },
    isFirstColumn(index) {
      return index === 0;
    },
    stageConnectorClass(index, stage) {
      let className;

      // If it's the first stage column and only has one job
      if (index === 0 && stage.groups.length === 1) {
        className = 'no-margin';
      } else if (index > 0) {
        // If it is not the first column
        className = 'left-margin';
      }

      return className;
    },
    refreshPipelineGraph() {
      this.$emit('refreshPipelineGraph');
    },
    /**
     * CSS class is applied:
     *  - to last stage column
     *
     * @param {number} index
     * @returns {boolean}
     */
    shouldAddRightMargin(index) {
      return !(index === this.stages.length - 1);
    },
  },
};
