<script>
/**
 * Common component to render a placeholder note and user information.
 *
 * This component needs to be used with a vuex store.
 * That vuex store needs to have a `getUserData` getter that contains
 * {
 *   path: String,
 *   avatar_url: String,
 *   name: String,
 *   username: String,
 * }
 *
 * @example
 * <placeholder-note
 *   :note="{body: 'This is a note'}"
 *   />
 */
import { GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import marked from 'marked';
import { mapGetters } from 'vuex';
import { sanitize } from '~/lib/dompurify';
import TimelineEntryItem from '~/vue_shared/components/notes/timeline_entry_item.vue';
import userAvatarLink from '../user_avatar/user_avatar_link.vue';

const renderer = new marked.Renderer();
marked.setOptions({
  renderer,
});

export default {
  name: 'PlaceholderNote',
  directives: { SafeHtml },
  components: {
    userAvatarLink,
    TimelineEntryItem,
  },
  props: {
    note: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['getUserData']),
    renderedNote() {
      return sanitize(marked(this.note.body), {
        // allowedTags from GitLab's inline HTML guidelines
        // https://docs.gitlab.com/ee/user/markdown.html#inline-html
        ALLOWED_TAGS: [
          'a',
          'abbr',
          'b',
          'blockquote',
          'br',
          'code',
          'dd',
          'del',
          'div',
          'dl',
          'dt',
          'em',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
          'hr',
          'i',
          'img',
          'ins',
          'kbd',
          'li',
          'ol',
          'p',
          'pre',
          'q',
          'rp',
          'rt',
          'ruby',
          's',
          'samp',
          'span',
          'strike',
          'strong',
          'sub',
          'summary',
          'sup',
          'table',
          'tbody',
          'td',
          'tfoot',
          'th',
          'thead',
          'tr',
          'tt',
          'ul',
          'var',
        ],
        ALLOWED_ATTR: ['class', 'style', 'href', 'src'],
        ALLOW_DATA_ATTR: false,
      });
    },
  },
};
</script>

<template>
  <timeline-entry-item class="note note-wrapper being-posted fade-in-half">
    <div class="timeline-icon">
      <user-avatar-link
        :link-href="getUserData.path"
        :img-src="getUserData.avatar_url"
        :img-size="40"
      />
    </div>
    <div ref="note" :class="{ discussion: !note.individual_note }" class="timeline-content">
      <div class="note-header">
        <div class="note-header-info">
          <a :href="getUserData.path">
            <span class="d-none d-sm-inline-block bold">{{ getUserData.name }}</span>
            <span class="note-headline-light">@{{ getUserData.username }}</span>
          </a>
        </div>
      </div>
      <div class="note-body">
        <div v-safe-html="renderedNote" class="note-text md"></div>
      </div>
    </div>
  </timeline-entry-item>
</template>
