<script>
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';

export default {
  components: {
    SidebarEditableItem,
  },
};
</script>

<template>
  <sidebar-editable-item :title="__('Confidentiality')" class="block">
    <template #collapsed>Collapsed!</template>
    <template #default>Expanded!</template>
  </sidebar-editable-item>
</template>
