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

  findById(id) {
    const cacheId = getGroupId(id);
    return this.cache.readFragment({ fragment: ImportSourceGroupFragment, id: cacheId });
  }

  update(group, fn) {
    this.cache.writeFragment({
      fragment: ImportSourceGroupFragment,
      id: getGroupId(group.id),
      data: produce(group, fn),
    });
  }

  updateById(id, fn) {
    const group = this.findById(id);
    this.update(group, fn);
  }

  setImportStatus({ group, status }) {
    this.update(group, sourceGroup => {
      // eslint-disable-next-line no-param-reassign
      sourceGroup.status = status;
    });
  }
}
