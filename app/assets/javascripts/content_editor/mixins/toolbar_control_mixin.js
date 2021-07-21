export default {
  inject: ['tiptapEditor'],
  created() {
    const component = this;
    const { onTiptapDocUpdate, onTiptapSelectionUpdate } = component.$options;

    if (typeof onTiptapDocUpdate === 'function') {
      this.docUpdateHandler = (params) => {
        onTiptapDocUpdate.call(component, params);
      };

      this.tiptapEditor?.on('update', this.docUpdateHandler);
    }

    if (typeof onTiptapSelectionUpdate === 'function') {
      this.selectionUpdateHandler = (params) => {
        onTiptapSelectionUpdate.call(component, params);
      };

      this.tiptapEditor?.on('selectionUpdate', this.selectionUpdateHandler);
    }
  },
  beforeDestroy() {
    this.tiptapEditor?.off('update', this.docUpdateHandler);
    this.tiptapEditor?.off('selectionUpdate', this.selectionUpdateHandler);
  },
};
