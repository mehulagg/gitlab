import $ from 'jquery';
import VariableList from '~/ci_variable_list/ci_variable_list';

describe('VariableList (EE features)', () => {
  preloadFixtures('projects/ci_cd_settings.html');

  let $wrapper;
  let variableList;

  describe('with all inputs(key, value, protected, environment)', () => {
    beforeEach(() => {
      loadFixtures('projects/ci_cd_settings.html');
      $wrapper = $('.js-ci-variable-list-section');

      variableList = new VariableList({
        container: $wrapper,
        formField: 'variables',
      });
      variableList.init();
    });

    describe('environment dropdown', () => {
      function addRowByNewEnvironment(newEnv) {
        const $row = $wrapper.find('.js-row:last-child');

        // Open the dropdown
        $row.find('.js-variable-environment-toggle').click();

        // Filter for the new item
        $row
          .find('.js-variable-environment-dropdown-wrapper .dropdown-input-field')
          .val(newEnv)
          .trigger('input');

        // Create the new item
        $row.find('.js-variable-environment-dropdown-wrapper .js-dropdown-create-new-item').click();
      }

      it('should add another row when editing the last rows environment dropdown', () => {
        addRowByNewEnvironment('someenv');

        jest.runOnlyPendingTimers();

        expect($wrapper.find('.js-row')).toHaveLength(2);

        // Check for the correct default in the new row
        const $environmentInput = $wrapper
          .find('.js-row:last-child')
          .find('input[name="variables[variables_attributes][][environment_scope]"]');

        expect($environmentInput.val()).toBe('*');
      });

      it('should update dropdown with new environment values and remove values when row is removed', () => {
        addRowByNewEnvironment('someenv');

        const $row = $wrapper.find('.js-row:last-child');
        $row.find('.js-variable-environment-toggle').click();

        jest.runOnlyPendingTimers();

        const $dropdownItemsBeforeRemove = $row.find(
          '.js-variable-environment-dropdown-wrapper .dropdown-content a',
        );

        expect($dropdownItemsBeforeRemove).toHaveLength(2);
        expect($dropdownItemsBeforeRemove[0].textContent.trim()).toBe('someenv');
        expect($dropdownItemsBeforeRemove[1].textContent.trim()).toBe('* (All environments)');

        $wrapper.find('.js-row-remove-button').trigger('click');

        expect($wrapper.find('.js-row')).toHaveLength(0);

        jest.runOnlyPendingTimers();

        const $dropdownItemsAfterRemove = $row.find(
          '.js-variable-environment-dropdown-wrapper .dropdown-content a',
        );

        expect($dropdownItemsAfterRemove).toHaveLength(1);
        expect($dropdownItemsAfterRemove[0].textContent.trim()).toBe('* (All environments)');
      });
    });
  });
});
