<script>
import {
  GlDropdown,
  GlDropdownForm,
  GlButton,
  GlFormInputGroup,
  GlDropdownDivider,
  GlDropdownItem,
} from '@gitlab/ui';
import { Editor as TiptapEditor } from '@tiptap/vue-2';

const linkContentType = 'link';

const markRange = ($cursor, markType) => {
  let startIndex = $cursor.index();
  let endIndex = $cursor.indexAfter();

  const hasMark = (index) => markType.isInSet($cursor.parent.child(index).marks);

  // Clicked outside edge of tag.
  if (startIndex === $cursor.parent.childCount) {
    startIndex -= 1;
  }
  while (startIndex > 0 && hasMark(startIndex)) {
    startIndex -= 1;
  }
  while (endIndex < $cursor.parent.childCount && hasMark(endIndex)) {
    endIndex += 1;
  }

  let startPos = $cursor.start();
  let endPos = startPos;

  for (let i = 0; i < endIndex; i += 1) {
    const size = $cursor.parent.child(i).nodeSize;
    if (i < startIndex) startPos += size;
    endPos += size;
  }

  return { from: startPos, to: endPos };
};

export default {
  components: {
    GlDropdown,
    GlDropdownForm,
    GlFormInputGroup,
    GlDropdownDivider,
    GlDropdownItem,
    GlButton,
  },
  props: {
    tiptapEditor: {
      type: TiptapEditor,
      required: true,
    },
  },
  data() {
    return {
      linkHref: '',
    };
  },
  computed: {
    isActive() {
      return this.tiptapEditor.isActive(linkContentType);
    },
  },
  mounted() {
    this.tiptapEditor.on('selectionUpdate', ({ editor }) => {
      const { href } = editor.getAttributes(linkContentType);

      this.linkHref = href;
    });
  },
  methods: {
    updateLink() {
      this.tiptapEditor.chain().focus().unsetLink().setLink({ href: this.linkHref }).run();
    },
    selectLink() {
      const { tiptapEditor } = this;
      const range = markRange(
        tiptapEditor.state.selection.$from,
        tiptapEditor.schema.mark(linkContentType),
      );

      this.tiptapEditor.chain().focus().setTextSelection(range).run();
    },
    removeLink() {
      this.tiptapEditor.chain().focus().unsetLink().run();
    },
  },
};
</script>
<template>
  <gl-dropdown
    :toggle-class="{ active: isActive }"
    size="small"
    category="tertiary"
    icon="link"
    @show="selectLink()"
  >
    <gl-dropdown-form class="gl-px-3!">
      <gl-form-input-group v-model="linkHref" :placeholder="__('Link URL')">
        <template #append>
          <gl-button variant="confirm" @click="updateLink">{{ __('Apply') }}</gl-button>
        </template>
      </gl-form-input-group>
    </gl-dropdown-form>
    <gl-dropdown-divider v-if="isActive" />
    <gl-dropdown-item v-if="isActive" @click="removeLink()">
      {{ __('Remove link') }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
