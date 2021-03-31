<script>
import {
  GlButton,
  GlDatepicker,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInput,
} from '@gitlab/ui';
import { visitUrl } from '~/lib/utils/url_utility';
import { s__ } from '~/locale';
import createCadence from '../queries/create_cadence.mutation.graphql';

export default {
  components: {
    GlButton,
    GlDatepicker,
    GlForm,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInput,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    cadencesListPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      cadences: [],
      loading: false,
      title: '',
      automatic: true,
      startDate: null,
      durationInWeeks: null,
      rollOverIssues: false,
      iterationsInAdvance: null,
      i18n: Object.freeze({
        duration: {
          description: s__('Iterations|The duration for each iteration (in weeks)'),
        },
      }),
    };
  },
  computed: {
    variables() {
      return {
        input: {
          groupPath: this.groupPath,
          title: this.title,
          automatic: this.automatic,
          startDate: this.startDate,
          durationInWeeks: this.durationInWeeks,
          iterationsInAdvance: this.iterationsInAdvance,
          active: true, // TODO: where is this toggled?
        },
      };
    },
  },
  methods: {
    save() {
      this.loading = true;
      return this.createCadence();
    },
    cancel() {
      if (this.cadencesListPath) {
        visitUrl(this.cadencesListPath);
      } else {
        this.$emit('cancel');
      }
    },
    createCadence() {
      return this.$apollo
        .mutate({
          mutation: createCadence,
          variables: this.variables,
        })
        .then(({ data }) => {
          const { errors, cadence } = data.createCadence;
          if (errors.length > 0) {
            this.loading = false;
            throw new Error(errors[0]);
            // createFlash(errors[0]);
          }

          visitUrl(cadence.webUrl);
        })
        .catch((e) => {
          this.loading = false;
          throw e;
          // createFlash(__('Unable to save cadence. Please try again'));
        });
    },
    updateStartDate(val) {
      this.startDate = val;
    },
  },
};
</script>

<template>
  <article>
    <div class="gl-display-flex">
      <h3 ref="pageTitle" class="page-title">
        {{ __('New iteration cadence') }}
      </h3>
    </div>
    <gl-form>
      <gl-form-group
        :label="__('Title')"
        :label-cols-md="2"
        label-class="text-right-md gl-pt-3!"
        label-for="cadence-title"
      >
        <!-- :invalid-feedback=""
              :state="validationState.name" -->
        <gl-form-input
          id="cadence-title"
          v-model="title"
          autocomplete="off"
          data-qa-selector="iteration_cadence_title_field"
          :placeholder="__('Cadence name')"
        />
      </gl-form-group>

      <gl-form-group
        :label-cols-md="2"
        label-class="gl-font-weight-bold text-right-md gl-pt-3!"
        label-for="cadence-automated-scheduling"
        :description="s__('Iterations|Iteration scheduling will be handled automatically')"
      >
        <gl-form-checkbox v-model="automatic">
          {{ s__('Iterations|Automated scheduling') }}
        </gl-form-checkbox>
      </gl-form-group>

      <gl-form-group
        :label="__('Start date')"
        :label-cols-md="2"
        label-class="text-right-md gl-pt-3!"
        label-for="start-date"
        :description="s__('Iterations|The start date of your first iteration')"
      >
        <gl-datepicker :target="null">
          <gl-form-input
            v-model="startDate"
            :placeholder="__('Select start date')"
            class="datepicker gl-datepicker-input"
            autocomplete="off"
            id="start-date"
            inputmode="none"
            required
            data-qa-selector="cadence_start_date"
          />
        </gl-datepicker>
      </gl-form-group>

      <gl-form-group
        :label="__('Duration')"
        :label-cols-md="2"
        label-class="text-right-md gl-pt-3!"
        label-for="cadence-duration"
        :description="i18n.duration.description"
      >
        <!-- :invalid-feedback=""
              :state="validationState.name" -->
        <gl-form-input
          id="cadence-duration"
          v-model.number="durationInWeeks"
          :placeholder="__('Select duration')"
          type="number"
          min="1"
          no-wheel
          autocomplete="off"
          data-qa-selector="iteration_cadence_name_field"
        />
      </gl-form-group>

      <gl-form-group
        :label="__('Future iterations')"
        :label-cols-md="2"
        :content-cols-md="2"
        label-class="text-right-md gl-pt-3!"
        label-for="cadence-schedule-future-iterations"
        :description="
          s__('Iterations|Number of future iterations you would like to have scheduled')
        "
      >
        <!-- :invalid-feedback=""
              :state="validationState.name" -->
        <gl-form-input
          id="cadence-schedule-future-iterations"
          v-model.number="iterationsInAdvance"
          type="number"
          min="1"
          no-wheel
          autocomplete="off"
          data-qa-selector="iteration_cadence_name_field"
        />
      </gl-form-group>

      <div class="form-actions d-flex">
        <gl-button
          :loading="loading"
          data-testid="save-cadence"
          variant="confirm"
          data-qa-selector="save_cadence_button"
          @click="save"
        >
          {{ __('Create cadence') }}
        </gl-button>
        <gl-button class="ml-auto" data-testid="cancel-create" @click="cancel">
          {{ __('Cancel') }}
        </gl-button>
      </div>
    </gl-form>
  </article>
</template>
