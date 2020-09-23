import '~/pages/projects/settings/operations/show/index';
import mountStatusPageForm from 'ee/status_page_settings';
import initSettingsPanels from '~/settings_panels';

document.addEventListener('DOMContentLoaded', () => {
  mountStatusPageForm();
  initSettingsPanels();
});
