import $ from 'jquery';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import Members from '~/members';

export default class MembersEE extends Members {
  addListeners() {
    super.addListeners();

    $('.js-ldap-permissions')
      .off('click')
      .on('click', this.showLDAPPermissionsWarning.bind(this));
    $('.js-ldap-override')
      .off('click')
      .on('click', this.toggleMemberAccessToggle.bind(this));
  }

  dropdownClicked(options) {
    options.e.preventDefault();

    const $link = options.$el;

    if (!$link.data('revert')) {
      this.formSubmit(null, $link);
    } else {
      const { $memberListItem, $toggle, $dateInput } = this.getMemberListItems($link);

      $toggle.disable();
      $dateInput.disable();

      MembersEE.overrideLdap($memberListItem, $link.data('endpoint'), false).catch(() => {
        $toggle.enable();
        $dateInput.enable();
      });
    }
  }

  dropdownToggleLabel(selected, $el, $btn) {
    if ($el.data('revert')) {
      return $btn.text();
    }

    return super.dropdownToggleLabel(selected, $el, $btn);
  }

  dropdownIsSelectable(selected, $el) {
    if ($el.data('revert')) {
      return false;
    }

    return super.dropdownIsSelectable(selected, $el);
  }

  showLDAPPermissionsWarning(e) {
    const $btn = $(e.currentTarget);
    const { $memberListItem } = this.getMemberListItems($btn);
    const $ldapPermissionsElement = $memberListItem.next();

    $ldapPermissionsElement.toggle();
  }

  toggleMemberAccessToggle(e) {
    const $btn = $(e.currentTarget);
    const { $memberListItem, $toggle, $dateInput } = this.getMemberListItems($btn);

    $btn.disable();
    MembersEE.overrideLdap($memberListItem, $btn.data('endpoint'), true)
      .then(() => {
        this.showLDAPPermissionsWarning(e);

        $toggle.enable();
        $dateInput.enable();
      })
      .catch(xhr => {
        $btn.enable();

        if (xhr.status === 403) {
          createFlash(
            __(
              'You do not have the correct permissions to override the settings from the LDAP group sync.',
            ),
          );
        } else {
          createFlash(__('An error occurred while saving LDAP override status. Please try again.'));
        }
      });
  }

  static overrideLdap($memberListitem, endpoint, override) {
    return axios
      .patch(endpoint, {
        group_member: {
          override,
        },
      })
      .then(() => {
        $memberListitem.toggleClass('is-overridden', override);
      });
  }
}
