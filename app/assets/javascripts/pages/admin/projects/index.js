import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';
import OldNamespaceSelect from '~/namespace_select';
import ProjectsList from '~/projects_list';
import RemoveMemberModal from '~/vue_shared/components/remove_member_modal.vue';
import NamespaceSelect from './components/namespace_select.vue';

function mountRemoveMemberModal() {
  const el = document.querySelector('.js-remove-member-modal');
  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render(createComponent) {
      return createComponent(RemoveMemberModal);
    },
  });
}

mountRemoveMemberModal();

new ProjectsList(); // eslint-disable-line no-new

document
  .querySelectorAll('.js-namespace-select')
  .forEach((dropdown) => new OldNamespaceSelect({ dropdown }));

function mountNamespaceSelect() {
  const el = document.querySelector('.js-new-namespace-select');
  if (!el) {
    return false;
  }

  const { showAny, fieldName, namespace, namespaceId, updateLocation } = el.dataset;

  return new Vue({
    el,
    render(createComponent) {
      return createComponent(NamespaceSelect, {
        props: {
          showAny: parseBoolean(showAny),
          initialNamespaceId: namespaceId,
          initialNamespace: namespace,
          fieldName,
        },
        on: {
          setNamespace(newNamespace) {
            if (fieldName && updateLocation) {
              window.location = mergeUrlParams({ [fieldName]: newNamespace }, window.location.href);
            }
          },
        },
      });
    },
  });
}

mountNamespaceSelect();
