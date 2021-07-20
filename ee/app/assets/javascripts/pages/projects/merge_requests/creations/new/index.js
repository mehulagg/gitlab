import '~/pages/projects/merge_requests/creations/new/index';
import { initPaidFeatureCalloutBadgeAndPopover } from 'ee/paid_feature_callouts/index';
import UserCallout from '~/user_callout';
import initForm from '../../shared/init_form';

initForm();
initPaidFeatureCalloutBadgeAndPopover();
// eslint-disable-next-line no-new
new UserCallout();
