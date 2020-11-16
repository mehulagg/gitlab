import $ from 'jquery';
import initDependencyProxy from 'ee/dependency_proxy';

initDependencyProxy();

const form = document.querySelector('form.edit_dependency_proxy_group_setting');
const toggleInput = $('input.js-project-feature-toggle-input');

if (form && toggleInput) {
  toggleInput.on('trigger-change', () => {
    form.submit();
  });
}
