import $ from 'jquery';
import '~/lib/utils/jquery_at_who';
import GfmAutoComplete from '~/gfm_auto_complete';

/**
 * This is added to keep the export parity with the CE counterpart.
 *
 * Some modules import `defaultAutocompleteConfig` or `membersBeforeSave`
 * which will be undefined if not exported from here in EE.
 */
export { defaultAutocompleteConfig, membersBeforeSave } from '~/gfm_auto_complete';

class GfmAutoCompleteEE extends GfmAutoComplete {
  setupAtWho($input) {
    if (this.enableMap.epics) {
      this.setupAutoCompleteEpics($input, this.getDefaultCallbacks());
    }

    super.setupAtWho($input);
  }

  setupAutoCompleteEpics = ($input, defaultCallbacks) => {
    $input.atwho({
      at: '&',
      alias: 'epics',
      searchKey: 'search',
      displayTpl(value) {
        let tmpl = GfmAutoComplete.Loading.template;
        if (value.title != null) {
          tmpl = GfmAutoComplete.Issues.templateFunction(value);
        }
        return tmpl;
      },
      data: GfmAutoComplete.defaultLoadingData,
      // eslint-disable-next-line no-template-curly-in-string
      insertTpl: '${atwho-at}${id}',
      callbacks: {
        ...defaultCallbacks,
        beforeSave(merges) {
          return $.map(merges, m => {
            if (m.title == null) {
              return m;
            }
            return {
              id: m.iid,
              title: m.title.replace(/<(?:.|\n)*?>/gm, ''),
              search: `${m.iid} ${m.title}`,
            };
          });
        },
      },
    });
  };
}

export default GfmAutoCompleteEE;
