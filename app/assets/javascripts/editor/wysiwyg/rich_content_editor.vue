<script>
import { EditorContent, EditorMenuBar } from 'tiptap';

import GlButton from '../base/button/button.vue';
import GlDropdown from '../base/dropdown/dropdown.vue';
import GlDropdownItem from '../base/dropdown/dropdown_item.vue';
import GlTooltip from '../../directives/tooltip';

import { headingLevels } from './constants';

import GlMarkdown from '../base/markdown/markdown.vue';

export default {
  components: {
    EditorContent,
    EditorMenuBar,
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlMarkdown,
  },
  directives: {
    GlTooltip,
  },
  props: {
    editor: {
      type: Object,
      required: true,
    },
  },
  beforeDestroy() {
    this.editor.destroy();
  },
  methods: {
    activeHeadingLabel(isActive) {
      const activeLevel = headingLevels.find(level => isActive.heading({ level }));

      return activeLevel ? `Heading ${activeLevel}` : 'Paragraph';
    },
  },
  headingLevels,
};
</script>
<template>
  <div>
    <editor-menu-bar :editor="editor">
      <template #default="{ commands, isActive }">
        <div class="gl-display-flex gl-justify-content-center gl-mb-3">
          <gl-dropdown class="gl-mr-2" category="tertiary" :text="activeHeadingLabel(isActive)">
            <gl-dropdown-item :active="isActive.paragraph()">Paragraph</gl-dropdown-item>
            <gl-dropdown-item
              v-for="level in $options.headingLevels"
              :key="level"
              :active="isActive.heading({ level })"
              @click="commands.heading({ level })"
              >Heading {{ level }}</gl-dropdown-item
            >
          </gl-dropdown>
          <gl-button
            v-gl-tooltip
            class="gl-mr-2"
            icon="bold"
            category="tertiary"
            :class="{ active: isActive.bold() }"
            title="Bold"
            @click="commands.bold"
          />
          <gl-button
            v-gl-tooltip
            class="gl-mr-2"
            icon="italic"
            category="tertiary"
            :class="{ active: isActive.italic() }"
            title="Italic"
            @click="commands.italic"
          />
          <span
            class="gl-border-r-solid gl-border-1 gl-border-gray-100 gl-h-7 gl-mr-2 gl-display-none! gl-display-sm-flex!"
          ></span>
          <gl-button
            v-gl-tooltip
            class="gl-mr-2 gl-display-none! gl-display-sm-flex!"
            icon="list-bulleted"
            category="tertiary"
            :class="{ active: isActive.bullet_list() }"
            title="Bullet list"
            @click="commands.bullet_list"
          />
          <gl-button
            v-gl-tooltip
            class="gl-mr-2 gl-display-none! gl-display-sm-flex!"
            icon="list-numbered"
            category="tertiary"
            :class="{ active: isActive.ordered_list() }"
            title="Ordered list"
            @click="commands.ordered_list"
          />
        </div>
      </template>
    </editor-menu-bar>
    <gl-markdown>
      <editor-content :editor="editor" />
    </gl-markdown>
  </div>
</template>
