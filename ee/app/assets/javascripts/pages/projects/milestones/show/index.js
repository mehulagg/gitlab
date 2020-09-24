import '~/pages/projects/milestones/show/index';
import initBurndownChart from 'ee/burndown_chart';
import UserCallout from '~/user_callout';

document.addEventListener('DOMContentLoaded', () => {
  new UserCallout(); // eslint-disable-line no-new
  initBurndownChart();
});
