import DueDateSelectors from '~/due_date_select';
import initSettingsPanels from '~/settings_panels';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize expandable settings panels
  initSettingsPanels();

  new DueDateSelectors(); // eslint-disable-line no-new
});
