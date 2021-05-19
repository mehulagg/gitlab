import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ToolbarTextStyleDropdown from '~/content_editor/components/toolbar_text_style_dropdown.vue';
import { TEXT_STYLE_DROPDOWN_ITEMS } from '~/content_editor/constants';
import { createContentEditor } from '~/content_editor/services/create_content_editor';

describe('content_editor/components/toolbar_headings_dropdown', () => {
  let wrapper;
  let tiptapEditor;

  const buildEditor = () => {
    tiptapEditor = createContentEditor({
      renderMarkdown: () => true,
    }).tiptapEditor;

    jest.spyOn(tiptapEditor, 'isActive');
  };

  const buildWrapper = (propsData = {}) => {
    wrapper = shallowMountExtended(ToolbarTextStyleDropdown, {
      stubs: {
        GlDropdown,
        GlDropdownItem,
      },
      propsData: {
        tiptapEditor,
        ...propsData,
      },
    });
  };
  const findDropdown = () => wrapper.findComponent(GlDropdown);

  beforeEach(() => {
    buildEditor();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders all text styles as dropdown items', () => {
    buildWrapper();

    TEXT_STYLE_DROPDOWN_ITEMS.forEach((heading) => {
      expect(wrapper.findByText(heading.label).exists()).toBe(true);
    });
  });

  describe('when there is an active item ', () => {
    let activeTextStyle;

    beforeEach(() => {
      [, activeTextStyle] = TEXT_STYLE_DROPDOWN_ITEMS;

      tiptapEditor.isActive.mockImplementation(
        (contentType, params) =>
          activeTextStyle.contentType === contentType && activeTextStyle.commandParams === params,
      );

      buildWrapper();
    });

    it('displays the active text style label as the dropdown toggle text ', () => {
      expect(findDropdown().props().text).toBe(activeTextStyle.label);
    });

    it('sets dropdown as enabled', () => {
      expect(findDropdown().props().disabled).toBe(false);
    });

    it('sets active item as active', () => {
      const activeItem = wrapper
        .findAllComponents(GlDropdownItem)
        .filter((item) => item.text() === activeTextStyle.label)
        .at(0);
      expect(activeItem.props().isChecked).toBe(true);
    });
  });

  describe('when there isn’t an active item', () => {
    beforeEach(() => {
      tiptapEditor.isActive.mockReturnValue(false);
      buildWrapper();
    });

    it('sets dropdown as disabled', () => {
      expect(findDropdown().props().disabled).toBe(true);
    });

    it('sets dropdown toggle text to Text style', () => {
      expect(findDropdown().props().text).toBe('Text style');
    });
  });
});
