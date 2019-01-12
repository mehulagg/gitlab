import $ from 'jquery';
import _ from 'underscore';
import { __ } from '~/locale';
import Flash from '~/flash';
import SSHMirror from './ssh_mirror';
import Api from '~/api';

export default class MirrorRepos {
  constructor(container) {
    this.$container = $(container);
    this.$password = null;
    this.$form = $('.js-mirror-form', this.$container);
    this.$urlInput = $('.js-mirror-url', this.$form);
    this.$protectedBranchesInput = $('.js-mirror-protected', this.$form);
    this.$table = $('.js-mirrors-table-body', this.$container);
  }

  init() {
    this.initMirrorPush();
    this.registerUpdateListeners();
  }

  initMirrorPush() {
    this.$passwordGroup = $('.js-password-group', this.$container);
    this.$password = $('.js-password', this.$passwordGroup);
    this.$authMethod = $('.js-auth-method', this.$form);

    this.$authMethod.on('change', () => this.togglePassword());
    this.$password.on('input.updateUrl', () => this.debouncedUpdateUrl());

    this.initMirrorSSH();
    this.updateProtectedBranches();
  }

  initMirrorSSH() {
    if (this.$password) {
      this.$password.off('input.updateUrl');
    }
    this.$password = undefined;

    this.sshMirror = new SSHMirror('.js-mirror-form');
    this.sshMirror.init();
  }

  updateUrl() {
    let val = this.$urlInput.val();

    if (this.$password) {
      const password = this.$password.val();
      if (password) val = val.replace('@', `:${password}@`);
    }

    $('.js-mirror-url-hidden', this.$form).val(val);
  }

  updateProtectedBranches() {
    const val = this.$protectedBranchesInput.get(0).checked
      ? this.$protectedBranchesInput.val()
      : '0';
    $('.js-mirror-protected-hidden', this.$form).val(val);
  }

  registerUpdateListeners() {
    this.debouncedUpdateUrl = _.debounce(() => this.updateUrl(), 200);
    this.$urlInput.on('input', () => this.debouncedUpdateUrl());
    this.$protectedBranchesInput.on('change', () => this.updateProtectedBranches());
    this.$table.on('click', '.js-delete-mirror', event =>
      this.deleteMirror($(event.currentTarget)),
    );
  }

  togglePassword() {
    const isPassword = this.$authMethod.val() === 'password';

    if (!isPassword) {
      this.$password.val('');
      this.updateUrl();
    }
    this.$passwordGroup.collapse(isPassword ? 'show' : 'hide');
  }

  deleteMirror($target) {
    return Api.deleteProjectRemoteMirror(this.$form.data('projectId'), $target.data('mirrorId'))
      .then(() => this.removeRow($target))
      .catch(({ response }) => {
        Flash(
          response.status === 404 ? __('Remote mirror not found.') : __('Failed to remove mirror.'),
        );
      });
  }

  /* eslint-disable class-methods-use-this */
  removeRow($target) {
    const row = $target.closest('tr');
    $('.js-delete-mirror', row).tooltip('hide');
    row.remove();
  }
  /* eslint-enable class-methods-use-this */
}
