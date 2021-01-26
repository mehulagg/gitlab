import '~/pages/groups/edit';
import validateRestrictedIpAddress from 'ee/groups/settings/access_restriction_field/validate_ip_address';
import initAccessRestrictionField from 'ee/groups/settings/access_restriction_field';
import createFlash from '~/flash';
import { __ } from '~/locale';

initAccessRestrictionField('.js-allowed-email-domains', {
  placeholder: __('Enter domain'),
  regexErrorMessage: __('The domain you entered is misformatted.'),
  disallowedValueErrorMessage: __('The domain you entered is not allowed.'),
});

initAccessRestrictionField(
  '.js-ip-restriction',
  { placeholder: __('Enter IP address range') },
  'ip_restriction_field',
  validateRestrictedIpAddress,
);

const complianceFrameworksList = document.querySelector('#js-compliance-frameworks-list');

if (complianceFrameworksList) {
  (async () => {
    try {
      const { createComplianceFrameworksListApp } = await import(
        /* webpackChunkName: 'createComplianceFrameworksListApp' */ 'ee/groups/settings/compliance_frameworks/init_list'
      );
      createComplianceFrameworksListApp(complianceFrameworksList);
    } catch {
      createFlash({ message: __('An error occurred while loading a section of this page.') });
    }
  })();
}
