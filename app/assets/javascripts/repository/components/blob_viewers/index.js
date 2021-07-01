export const loadViewer = (type) => {
  switch (type) {
    case 'empty':
      return import(/* webpackChunkName: 'blob_empty_viewer' */ './empty_viewer.vue');
    default:
      return null;
  }
};
