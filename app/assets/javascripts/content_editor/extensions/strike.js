import { Strike } from '@tiptap/extension-strike';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export const tiptapExtension = Strike;
export const serializer = defaultMarkdownSerializer.marks.strike;
