import CiTemplate from 'ee/pages/admin/application_settings/ci_cd/ci_template';
import { setHTMLFixture } from 'helpers/fixtures';

const DROPDOWN_DATA = {
  Instance: [{ name: 'test', id: 'test' }],
  General: [{ name: 'Android', id: 'Android' }],
};
const INITIAL_VALUE = 'Android';

describe('CI Template Dropdown (ee/pages/admin/application_settings/ci_cd/ci_template.js', () => {
  let CiTemplateInstance;

  beforeEach(() => {
    setHTMLFixture(`
      <div>
        <button class="js-ci-template-dropdown" data-data=${JSON.stringify(DROPDOWN_DATA)}>
          <span class="dropdown-toggle-text"></span>
        </button>
        <input id="required_instance_ci_template_name" value="${INITIAL_VALUE}" />
      </div>
    `);
    CiTemplateInstance = new CiTemplate();
  });

  describe('Init Dropdown', () => {
    it('Instantiates dropdown objects', () => {
      expect(CiTemplateInstance.$input).toHaveLength(1);
      expect(CiTemplateInstance.$dropdown).toHaveLength(1);
      expect(CiTemplateInstance.$dropdownToggle).toHaveLength(1);
    });

    it('Sets the dropdown text value', () => {
      expect(CiTemplateInstance.$dropdown.text().trim()).toBe(INITIAL_VALUE);
    });
  });

  describe('Format dropdown list', () => {
    it('Adds a reset option and divider', () => {
      const expected = {
        Reset: [{ name: 'No required pipeline', id: null }, { type: 'divider' }],
        ...DROPDOWN_DATA,
      };
      const actual = CiTemplateInstance.formatDropdownList();

      expect(JSON.stringify(actual)).toBe(JSON.stringify(expected));
    });
  });

  describe('Update input value', () => {
    it('changes the value of the input', () => {
      const selectedObj = { name: 'update', id: 'update' };
      const e = { preventDefault: () => {} };
      CiTemplateInstance.updateInputValue({ selectedObj, e });

      expect(CiTemplateInstance.$input.val()).toBe('update');
    });
  });
});
