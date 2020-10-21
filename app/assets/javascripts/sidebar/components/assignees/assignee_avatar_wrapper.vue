<script>
export default {};
</script>

<template>
  <assignee-avatar-link :user="item">
    <span class="d-flex gl-flex-direction-column gl-overflow-hidden">
      <strong class="dropdown-menu-user-full-name">
        {{ item.name }}
      </strong>
      <span class="dropdown-menu-user-username">@{{ item.username }}</span>
    </span>
  </assignee-avatar-link>
</template>
