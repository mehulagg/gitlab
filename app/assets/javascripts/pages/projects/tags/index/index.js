import initConfirmModal from '~/confirm_modal';

function handleRemoveTag(event) {
  event.preventDefault();
  const { currentTarget } = event;
  // confirm: s_('TagsPage|Deleting the %{tag_name} tag cannot be undone. Are you sure?') %
  //   { tag_name: tag.name };
  console.log('handleRemoveTag::event', event);
  console.log('handleRemoveTag::currentTarget', currentTarget);
}

document.addEventListener('DOMContentLoaded', () => {
  initConfirmModal();

  // document
  //   .querySelectorAll('.js-remove-tag')
  //   // .forEach(btn => btn.addEventListener('click', handleRemoveTag))
  //   .forEach(btn => btn.addEventListener('click', handleRemoveTag));
});
