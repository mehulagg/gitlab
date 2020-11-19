import { Editor } from 'tiptap';
import { Heading } from 'tiptap-extensions';
import { headingLevels } from '../constants';
import editorExtensions from '~/behaviors/markdown/editor_extensions';

export const build = args => {
  const { extensions, ...options} = args;
  return new Editor({
    extensions: [
      ...editorExtensions,
      new Heading({ levels: headingLevels }),
      ...extensions,
    ],
    ...options,
  });
};
