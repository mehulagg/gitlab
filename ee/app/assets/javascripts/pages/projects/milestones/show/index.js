import '~/pages/projects/milestones/show/index';
import initBurndownChart from 'ee/burndown_chart';
import UserCallout from '~/user_callout';

new UserCallout(); // eslint-disable-line no-new
initBurndownChart();
