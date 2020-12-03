import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import produce from 'immer';
import ImportSourceGroupFragment from '../fragments/bulk_import_source_group_item.fragment.graphql';

function extractTypeConditionFromFragment(fragment) {
  return fragment.definitions[0]?.typeCondition.name.value;
}

function getGroupId(id) {
  return defaultDataIdFromObject({
    __typename: extractTypeConditionFromFragment(ImportSourceGroupFragment),
    id,
  });
}

export class SourceGroupsManager {
  constructor({ cache }) {
    this.cache = cache;
  }

  findSourceGroupById(id) {
    const cacheId = getGroupId(id);
    return this.cache.readFragment({ fragment: ImportSourceGroupFragment, id: cacheId });
  }

  updateSourceGroup(group, fn) {
    this.cache.writeFragment({
      fragment: ImportSourceGroupFragment,
      id: getGroupId(group.id),
      data: produce(group, fn),
    });
  }

  updateSourceGroupById(id, fn) {
    const group = this.findSourceGroupById(id);
    this.updateSourceGroup(group, fn);
  }

  setImportStatus({ group, status }) {
    this.updateSourceGroup(group, sourceGroup => {
      // eslint-disable-next-line no-param-reassign
      sourceGroup.status = status;
    });
  }
}
