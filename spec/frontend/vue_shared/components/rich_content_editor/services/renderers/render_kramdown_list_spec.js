import renderer from '~/vue_shared/components/rich_content_editor/services/renderers/render_kramdown_list';
import { renderUneditableBranch } from '~/vue_shared/components/rich_content_editor/services/renderers/render_utils';

import { buildMockTextNode } from './mock_data';

const buildMockListNode = (literal) => {
  return {
    firstChild: {
      firstChild: {
        firstChild: buildMockTextNode(literal),
        type: 'paragraph',
      },
      type: 'item',
    },
    type: 'list',
  };
};

const normalListNode = buildMockListNode('Just another bullet point');
const kramdownListNode = buildMockListNode('TOC');

describe('Render Kramdown List renderer', () => {
  describe('canRender', () => {
    it('should return true when the argument is a special kramdown TOC ordered/unordered list', () => {
      expect(renderer.canRender(kramdownListNode)).toBe(true);
    });

    it('should return false when the argument is a normal ordered/unordered list', () => {
      expect(renderer.canRender(normalListNode)).toBe(false);
    });
  });

  describe('render', () => {
    it('should delegate rendering to the renderUneditableBranch util', () => {
      expect(renderer.render).toBe(renderUneditableBranch);
    });
  });
});
