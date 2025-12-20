/* global settings */
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { i18n } from "discourse-i18n";
import QuickEventModal from "./modal/quick-event-modal";

export default class QuickEventButton extends Component {
  @service modal;
  @service currentUser;
  @service siteSettings;

  get shouldRender() {
    return this.currentUser;
  }

  get buttonIcon() {
    return settings.quick_event_button_icon || "calendar-plus";
  }

  get buttonLabel() {
    const label = settings.quick_event_button_label;
    return label && label.trim() !== "" ? label : null;
  }

  get buttonTitle() {
    return i18n("quick_event.button_title");
  }

  @action
  openEventModal() {
    this.modal.show(QuickEventModal);
  }

  <template>
    {{#if this.shouldRender}}
      <li class="quick-event-header-button">
        <DButton
          @action={{this.openEventModal}}
          @icon={{this.buttonIcon}}
          @label={{this.buttonLabel}}
          @title={{this.buttonTitle}}
          class="btn-flat icon header-quick-event-btn"
        />
      </li>
    {{/if}}
  </template>
}
