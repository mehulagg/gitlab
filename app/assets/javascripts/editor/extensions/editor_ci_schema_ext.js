import { languages as monacoLanguages } from 'monaco-editor';
import Api from '~/api';
import { registerSchema } from '~/ide/utils';
import { EXTENSION_CI_SCHEMA_FILE_NAME_MATCH } from '../constants';
import { EditorLiteExtension } from './editor_lite_extension_base';

function createDependencyProposals(keyword, range) {
  // returning a static list of proposals, not even looking at the prefix (filtering is done by the Monaco editor),
  // here you could do a server side lookup
  if (keyword === 'image') {
    return [
      {
        label: 'alpine',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Alpine Docker image',
        insertText: ' alpine:latest',
        range,
      },
      {
        label: 'node',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Node Docker image',
        insertText: ' node:latest',
        range,
      },
      {
        label: 'ruby',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Ruby Docker image',
        insertText: ' ruby:latest',
        range,
      },
    ];
  }
  if (keyword === 'when') {
    return [
      {
        label: 'on_success',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation:
          'Execute job only when all jobs in earlier stages succeed, or are considered successful because they have allow_failure: true',
        insertText: ' on_success',
        range,
      },
      {
        label: 'on_failure',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Execute job only when at least one job in an earlier stage fails.',
        insertText: ' on_failure',
        range,
      },
      {
        label: 'always',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Execute job regardless of the status of jobs in earlier stages. ',
        insertText: ' always',
        range,
      },
      {
        label: 'manual',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Execute job manually. ',
        insertText: ' manual',
        range,
      },
      {
        label: 'delayed',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Delay the execution of a job for a specified duration',
        insertText: ' delayed\nstart_in: ',
        range,
      },
      {
        label: 'never',
        kind: monacoLanguages.CompletionItemKind.Function,
        documentation: 'Never execute this job',
        insertText: ' never',
        range,
      },
    ];
  }

  return [];
}

export class CiSchemaExtension extends EditorLiteExtension {
  /**
   * Registers a syntax schema to the editor based on project
   * identifier and commit.
   *
   * The schema is added to the file that is currently edited
   * in the editor.
   *
   * @param {Object} opts
   * @param {String} opts.projectNamespace
   * @param {String} opts.projectPath
   * @param {String?} opts.ref - Current ref. Defaults to master
   */
  // constructor() {
  //   super();
  //   this.registerAutocompleteProvider();
  // }

  registerCiSchema({ projectNamespace, projectPath, ref = 'master' } = {}) {
    const ciSchemaPath = Api.buildUrl(Api.projectFileSchemaPath)
      .replace(':namespace_path', projectNamespace)
      .replace(':project_path', projectPath)
      .replace(':ref', ref)
      .replace(':filename', EXTENSION_CI_SCHEMA_FILE_NAME_MATCH);
    // In order for workers loaded from `data://` as the
    // ones loaded by monaco editor, we use absolute URLs
    // to fetch schema files, hence the `gon.gitlab_url`
    // reference. This prevents error:
    //   "Failed to execute 'fetch' on 'WorkerGlobalScope'"
    const absoluteSchemaUrl = gon.gitlab_url + ciSchemaPath;
    const modelFileName = this.getModel().uri.path.split('/').pop();
    console.log(modelFileName);

    registerSchema({
      uri: absoluteSchemaUrl,
      fileMatch: [modelFileName],
    });
  }

  // eslint-disable-next-line class-methods-use-this
  registerAutocompleteProvider() {
    monacoLanguages.registerCompletionItemProvider('yaml', {
      // Which character triggers the suggestions, in this case
      // the column makes sense because of yaml structure.
      triggerCharacters: [':'],
      provideCompletionItems(model, position) {
        // find out if we are completing a property in the 'dependencies' object.
        const textUntilPosition = model.getValueInRange({
          // Getting position.lineNumber as the start and end number mean that
          // we are only giving suggestions when the word match is on the
          // same line as the currently typing user.
          startLineNumber: position.lineNumber,
          startColumn: 1,
          endLineNumber: position.lineNumber,
          endColumn: position.column,
        });

        let keyword;
        // We can define each keyword we want to give suggestions
        // for and then pass a CONSTANT to createDependencyProposals
        // function which will return the suggestions based on which
        // keyword was found.
        const imageMatch = textUntilPosition.match(/image:/);
        const whenMatch = textUntilPosition.match(/when:/);

        if (imageMatch) {
          keyword = 'image';
        } else if (whenMatch) {
          keyword = 'when';
        }

        const word = model.getWordUntilPosition(position);
        // This range is specifically to give monaco the coordinate
        // of where to insert the text.
        const range = {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: word.startColumn,
          endColumn: word.endColumn,
        };
        return {
          suggestions: createDependencyProposals(keyword, range),
        };
      },
    });
  }
}
