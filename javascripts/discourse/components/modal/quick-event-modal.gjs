/* global settings, themePrefix */
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
// import { i18n } from "discourse-i18n";
import { htmlSafe } from "@ember/template";

export default class QuickEventModal extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;

  constructor() {
    super(...arguments);
    this.title = "Go Sailing with " + this.currentUser.name.split(" ")[0];
  }

  @tracked title = "";
  @tracked description = "";
  @tracked startDate = "";
  @tracked startTime = "09:00";
  @tracked endDate = "";
  @tracked endTime = "16:00";
  @tracked maxAttendees = "";
  @tracked isSubmitting = false;
  @tracked errorMessage = "";

  get categoryId() {
    return settings.quick_event_category_id || 0;
  }

  get eventStatus() {
    return settings.quick_event_default_status || "public";
  }

  get showMaxAttendees() {
    return settings.quick_event_show_max_attendees;
  }

  get isValid() {
    return (
      this.title.trim() !== "" &&
      this.startDate !== "" &&
      this.categoryId > 0
    );
  }

  get validationMessage() {
    if (this.categoryId === 0) {
      // return i18n("quick_event.errors.no_category");
      return "Please configure a category in the theme component settings.";
    }
    if (!this.title.trim()) {
      // return i18n("quick_event.errors.no_title");
      return "Please enter an event title.";
    }
    if (!this.startDate) {
      // return i18n("quick_event.errors.no_start_date");
      return "Please select a start date.";
    }
    return "";
  }

  get todayDate() {
    return new Date().toISOString().split("T")[0];
  }

  get userTimezone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  }

  get modalTitle() {
    // return i18n("quick_event.modal_title");
    return "Go Sailing!";
  }

  get titleLabel() {
    // return i18n("quick_event.title_label");
    return "Event Title";
  }

  get titlePlaceholder() {
    // return i18n("quick_event.title_placeholder");
    return "Enter event title...";
  }

  get descriptionLabel() {
    // return i18n("quick_event.description_label");
    return "Description";
  }

  get descriptionPlaceholder() {
    // return i18n("quick_event.description_placeholder");
    return "Be honest!  Do you want an intense practice session, or a relaxing cruise?";
  }

  get startLabel() {
    // return i18n("quick_event.start_label");
    return "Start";
  }

  get endLabel() {
    // return i18n("quick_event.end_label");
    return "End";
  }

  get maxAttendeesLabel() {
    // return i18n("quick_event.max_attendees_label");
    return "Maximum Attendees";
  }

  get maxAttendeesPlaceholder() {
    // return i18n("quick_event.max_attendees_placeholder");
    return "Leave empty for unlimited";
  }

  get createButtonLabel() {
    // return i18n("quick_event.create_button");
    return "Create Event";
  }

  get cancelButtonLabel() {
    // return i18n("quick_event.cancel_button");
    return "Cancel";
  }

  formatDateTime(date, time) {
    if (!date) return null;
    // Format: YYYY-MM-DD HH:mm
    return `${date} ${time || "00:00"}`;
  }

  buildEventMarkdown() {
    const start = this.formatDateTime(this.startDate, this.startTime);
    const end = this.formatDateTime(this.endDate, this.endTime);
    
    // Build event attributes
    const eventAttrs = [
      `name="${this.title.trim()}"`,
      `start="${start}"`,
      `status="${this.eventStatus}"`,
      `timezone="${this.userTimezone}"`,
      `showLocalTime="true"`,
    ];
    
    if (end && this.endDate) {
      eventAttrs.push(`end="${end}"`);
    }

    if (this.showMaxAttendees && this.maxAttendees && this.maxAttendees.trim() !== "") {
      eventAttrs.push(`maxAttendees="${this.maxAttendees.trim()}"`);
    }

    // Description goes inside the event block
    const descriptionText = this.description.trim() ? this.description.trim() + "\n\n" : "";

    return `[event ${eventAttrs.join(" ")}]\n${descriptionText}[/event]`;
  }

  @action
  updateTitle(event) {
    this.title = event.target.value;
  }

  @action
  updateDescription(event) {
    this.description = event.target.value;
  }

  @action
  updateStartDate(event) {
    this.startDate = event.target.value;
    // If end date is empty or before start date, set it to start date
    if (!this.endDate || this.endDate < this.startDate) {
      this.endDate = this.startDate;
    }
  }

  @action
  updateStartTime(event) {
    this.startTime = event.target.value;
  }

  @action
  updateEndDate(event) {
    this.endDate = event.target.value;
  }

  @action
  updateEndTime(event) {
    this.endTime = event.target.value;
  }

  @action
  updateMaxAttendees(event) {
    this.maxAttendees = event.target.value;
  }

  @action
  async createEvent() {
    if (!this.isValid) {
      this.errorMessage = this.validationMessage;
      return;
    }

    this.isSubmitting = true;
    this.errorMessage = "";

    try {
      const postContent = this.buildEventMarkdown();

      const result = await ajax("/posts", {
        type: "POST",
        data: {
          title: this.title,
          raw: postContent,
          category: this.categoryId,
          archetype: "regular",
        },
      });

      // Close modal and navigate to new topic
      this.args.closeModal();
      
      if (result && result.topic_id) {
        this.router.transitionTo("topic", result.topic_slug, result.topic_id);
      }
    } catch (error) {
      popupAjaxError(error);
      // this.errorMessage = i18n("quick_event.errors.create_failed");
      this.errorMessage = "Failed to create event. Please try again.";
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    <DModal
      @title={{this.modalTitle}}
      @closeModal={{@closeModal}}
      class="quick-event-modal"
    >
      <:body>
        <div class="quick-event-form">
          {{#if this.errorMessage}}
            <div class="alert alert-error quick-event-error">
              {{this.errorMessage}}
            </div>
          {{/if}}

          <div class="control-group">
            <label for="event-title">{{this.titleLabel}} <span class="required">*</span></label>
            <input
              type="text"
              id="event-title"
              value={{this.title}}
              {{on "input" this.updateTitle}}
              placeholder={{this.titlePlaceholder}}
              class="quick-event-input"
              disabled={{this.isSubmitting}}
            />
          </div>

          <div class="control-group">
            <label for="event-description">{{this.descriptionLabel}}</label>
            <textarea
              id="event-description"
              value={{this.description}}
              {{on "input" this.updateDescription}}
              placeholder={{this.descriptionPlaceholder}}
              class="quick-event-textarea"
              rows="4"
              disabled={{this.isSubmitting}}
            ></textarea>
          </div>

          <div class="quick-event-datetime-row">
            <div class="control-group datetime-group">
              <label>{{this.startLabel}} <span class="required">*</span></label>
              <div class="datetime-inputs">
                <input
                  type="date"
                  value={{this.startDate}}
                  {{on "input" this.updateStartDate}}
                  min={{this.todayDate}}
                  class="quick-event-date"
                  disabled={{this.isSubmitting}}
                />
                <input
                  type="time"
                  value={{this.startTime}}
                  {{on "input" this.updateStartTime}}
                  class="quick-event-time"
                  disabled={{this.isSubmitting}}
                />
              </div>
            </div>

            <div class="control-group datetime-group">
              <label>{{this.endLabel}}</label>
              <div class="datetime-inputs">
                <input
                  type="date"
                  value={{this.endDate}}
                  {{on "input" this.updateEndDate}}
                  min={{this.startDate}}
                  class="quick-event-date"
                  disabled={{this.isSubmitting}}
                />
                <input
                  type="time"
                  value={{this.endTime}}
                  {{on "input" this.updateEndTime}}
                  class="quick-event-time"
                  disabled={{this.isSubmitting}}
                />
              </div>
            </div>
          </div>

          {{#if this.showMaxAttendees}}
            <div class="control-group">
              <label for="event-max-attendees">{{this.maxAttendeesLabel}}</label>
              <input
                type="number"
                id="event-max-attendees"
                value={{this.maxAttendees}}
                {{on "input" this.updateMaxAttendees}}
                placeholder={{this.maxAttendeesPlaceholder}}
                class="quick-event-input quick-event-number"
                min="1"
                disabled={{this.isSubmitting}}
              />
            </div>
          {{/if}}
        </div>
      </:body>

      <:footer>
        <DButton
          @action={{this.createEvent}}
          @translatedLabel={{this.createButtonLabel}}
          @icon="calendar-plus"
          @disabled={{this.isSubmitting}}
          class="btn-primary"
        />
        <DButton
          @action={{@closeModal}}
          @translatedLabel={{this.cancelButtonLabel}}
          @disabled={{this.isSubmitting}}
          class="btn-flat"
        />
      </:footer>
    </DModal>
  </template>
}
