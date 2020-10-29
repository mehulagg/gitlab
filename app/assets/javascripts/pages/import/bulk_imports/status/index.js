import { mountImportGroupsApp } from '~/import_entities/import_groups';

document.addEventListener('DOMContentLoaded', () => {
  const mountElement = document.getElementById('import-groups-mount-element');

  mountImportGroupsApp(mountElement);
});
