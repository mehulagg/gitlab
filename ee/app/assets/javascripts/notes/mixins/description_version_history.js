export default {
  data() {
    return {
      isDescriptionVersionExpanded: false,
      deleteInProgress: false,
    };
  },
  computed: {
    canSeeDescriptionVersion() {
      return Boolean(
        this.note.description_diff_path &&
          this.note.description_version_id &&
          !this.note.description_version_deleted,
      );
    },
    displayDeleteButton() {
      return (
        this.note.can_delete_description_version &&
        !this.deleteInProgress &&
        !this.note.description_version_deleted
      );
    },
    shouldShowDescriptionVersion() {
      return this.canSeeDescriptionVersion && this.isDescriptionVersionExpanded;
    },
    descriptionVersionToggleIcon() {
      return this.isDescriptionVersionExpanded ? 'chevron-up' : 'chevron-down';
    },
  },
  methods: {
    toggleDescriptionVersion() {
      this.isDescriptionVersionExpanded = !this.isDescriptionVersionExpanded;
      const versionId = this.note.description_version_id;

      if (this.descriptionVersions?.[versionId]) {
        return false;
      }

      const endpoint = this.note.description_diff_path;
      const startingVersion = this.note.start_description_version_id;

      return this.fetchDescriptionVersion({ endpoint, startingVersion, versionId });
    },
    deleteDescriptionVersion() {
      const endpoint = this.note.delete_description_version_path;
      const startingVersion = this.note.start_description_version_id;
      const versionId = this.note.description_version_id;
      this.deleteInProgress = true;
      return this.softDeleteDescriptionVersion({ endpoint, startingVersion, versionId }).catch(
        () => {
          this.deleteInProgress = false;
        },
      );
    },
  },
};
