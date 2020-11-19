import { CodeBlockHighlight } from 'tiptap-extensions';
import yaml from 'highlight.js/lib/languages/yaml';

// eslint-disable-next-line import/no-default-export
export default class FrontmatterCodeBlock extends CodeBlockHighlight {
  // eslint-disable-next-line class-methods-use-this
  get name() {
    return 'frontmatter';
  }

  constructor() {
    super({
      languages: {
        yaml,
      },
    });
  }
}
