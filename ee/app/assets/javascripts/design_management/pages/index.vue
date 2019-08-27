<script>
import { GlLoadingIcon, GlEmptyState } from '@gitlab/ui';
import _ from 'lodash-es';
import createFlash from '~/flash';
import { s__, sprintf } from '~/locale';
import DesignList from '../components/list/index.vue';
import UploadForm from '../components/upload/form.vue';
import UploadButton from '../components/upload/button.vue';
import uploadDesignMutation from '../graphql/mutations/uploadDesign.mutation.graphql';
import permissionsQuery from '../graphql/queries/permissions.query.graphql';
import allDesignsMixin from '../mixins/all_designs';
import projectQuery from '../graphql/queries/project.query.graphql';

const MAXIMUM_FILE_UPLOAD_LIMIT = 10;

export default {
  components: {
    GlLoadingIcon,
    DesignList,
    UploadForm,
    UploadButton,
    GlEmptyState,
  },
  mixins: [allDesignsMixin],
  apollo: {
    permissions: {
      query: permissionsQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          iid: this.issueIid,
        };
      },
      update: data => data.project.issue.userPermissions,
    },
  },
  data() {
    return {
      permissions: {
        createDesign: false,
      },
      isSaving: false,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.designs.loading || this.$apollo.queries.permissions.loading;
    },
    canCreateDesign() {
      return this.permissions.createDesign;
    },
    showUploadForm() {
      return this.canCreateDesign && this.hasDesigns;
    },
    hasDesigns() {
      return this.designs.length > 0;
    },
  },
  methods: {
    onUploadDesign(files) {
      if (!this.canCreateDesign) return null;

      if (files.length >= MAXIMUM_FILE_UPLOAD_LIMIT) {
        createFlash(
          sprintf(
            s__(
              'DesignManagement|The maximum number of designs allowed to be uploaded is %{upload_limit}. Please try again.',
            ),
            {
              upload_limit: MAXIMUM_FILE_UPLOAD_LIMIT,
            },
          ),
        );

        return null;
      }

      const optimisticResponse = Array.from(files).map(file => ({
        // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
        // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
        __typename: 'Design',
        id: -_.uniqueId(),
        image: '',
        filename: file.name,
        fullPath: '',
        diffRefs: {
          __typename: 'DiffRefs',
          baseSha: '',
          startSha: '',
          headSha: '',
        },
        versions: {
          __typename: 'DesignVersionConnection',
          edges: {
            __typename: 'DesignVersionEdge',
            node: {
              __typename: 'DesignVersion',
              id: -_.uniqueId(),
              sha: -_.uniqueId(),
            },
          },
        },
      }));

      this.isSaving = true;

      return this.$apollo
        .mutate({
          mutation: uploadDesignMutation,
          variables: {
            files,
            projectPath: this.projectPath,
            iid: this.issueIid,
          },
          context: {
            hasUpload: true,
          },
          update: (store, { data: { designManagementUpload } }) => {
            const data = store.readQuery({
              query: projectQuery,
              variables: { fullPath: this.projectPath, iid: this.issueIid, atVersion: null },
            });

            const newDesigns = data.project.issue.designs.designs.edges.reduce((acc, design) => {
              if (!acc.find(d => d.filename === design.node.filename)) {
                acc.push(design.node);
              }

              return acc;
            }, designManagementUpload.designs);

            let newVersionNode;
            const findNewVersions = designManagementUpload.designs.find(design => design.versions);

            if (findNewVersions) {
              const findNewVersionsEdges = findNewVersions.versions.edges;

              if (findNewVersionsEdges && findNewVersionsEdges.length) {
                newVersionNode = [findNewVersionsEdges[0]];
              }
            }

            const newVersions = [
              ...(newVersionNode || []),
              ...data.project.issue.designs.versions.edges,
            ];

            const newQueryData = {
              project: {
                // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
                // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
                __typename: 'Project',
                id: '',
                issue: {
                  // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
                  // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
                  __typename: 'Issue',
                  designs: {
                    __typename: 'DesignCollection',
                    designs: {
                      __typename: 'DesignConnection',
                      edges: newDesigns.map(design => ({
                        __typename: 'DesignEdge',
                        node: design,
                      })),
                    },
                    versions: {
                      __typename: 'DesignVersionConnection',
                      edges: newVersions,
                    },
                  },
                },
              },
            };

            store.writeQuery({
              query: projectQuery,
              variables: { fullPath: this.projectPath, iid: this.issueIid, atVersion: null },
              data: newQueryData,
            });
          },
          optimisticResponse: {
            // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
            // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
            __typename: 'Mutation',
            designManagementUpload: {
              __typename: 'DesignManagementUploadPayload',
              designs: optimisticResponse,
            },
          },
        })
        .then(() => {
          this.$router.push({ name: 'designs' });
        })
        .catch(e => {
          createFlash(s__('DesignManagement|Error uploading a new design. Please try again'));
          throw e;
        })
        .finally(() => {
          this.isSaving = false;
        });
    },
  },
};
</script>

<template>
  <div>
    <upload-form
      v-if="showUploadForm"
      :can-upload-design="canCreateDesign"
      :is-saving="isSaving"
      :all-versions="allVersions"
      @upload="onUploadDesign"
    />
    <div class="mt-4">
      <gl-loading-icon v-if="isLoading" size="md" />
      <div v-else-if="error" class="alert alert-danger">
        {{ __('An error occurred while loading designs. Please try again.') }}
      </div>
      <design-list v-else-if="hasDesigns" :designs="designs" />
      <gl-empty-state
        v-else
        :title="s__('DesignManagement|The one place for your designs')"
        :description="
          s__(`DesignManagement|Upload and view the latest designs for this issue.
            Consistent and easy to find, so everyone is up to date.`)
        "
      >
        <template #actions>
          <div v-if="canCreateDesign" class="center">
            <upload-button :is-saving="isSaving" @upload="onUploadDesign" />
          </div>
        </template>
      </gl-empty-state>
    </div>
    <router-view />
  </div>
</template>
