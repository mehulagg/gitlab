<script>
export default {
  name: 'ReplyPlaceholder',
  props: {
    placeholderText: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <textarea
    rows="1"
    class="reply-placeholder-text-field js-vue-discussion-reply"
    :placeholder="placeholderText"
    :title="s__('MergeRequests|Add a reply')"
    @focus="$emit('focus')"
  ></textarea>
</template>
