import { apiInitializer } from "discourse/lib/api";
import QuickEventModal from "../components/modal/quick-event-modal";

// discourse-calendar's category calendar opens a new-topic composer when an empty day
// is clicked, and (as of the bundled version) fires it twice — producing a stuck
// "Do you want to discard your post?" dialog plus a stray composer. That's confusing,
// heavyweight UX. Intercept the click gesture before FullCalendar handles it and open
// the simple Quick Event modal instead, pre-filled with the clicked date.
export default apiInitializer("1.0", (api) => {
  const currentUser = api.getCurrentUser();
  if (!currentUser) {
    return;
  }

  const modal = api.container.lookup("service:modal");

  // The empty area of a FullCalendar day cell — NOT an event, NOT the day-number link,
  // and NOT a [calendar] embedded in a post (those keep their normal behavior).
  const emptyCalendarDay = (target) => {
    if (!target || !target.closest) {
      return null;
    }
    const cell = target.closest("td.fc-daygrid-day[data-date]");
    if (!cell) {
      return null;
    }
    if (target.closest(".fc-event, .fc-daygrid-event, .fc-daygrid-day-number")) {
      return null;
    }
    if (target.closest(".cooked")) {
      return null;
    }
    return cell;
  };

  const onCalendarPointer = (event) => {
    const cell = emptyCalendarDay(event.target);
    if (!cell) {
      return;
    }

    // Stop FullCalendar (and thus discourse-calendar's date-click handler) from running.
    event.stopImmediatePropagation();
    event.preventDefault();

    // Only act once per click gesture.
    if (event.type !== "click") {
      return;
    }

    // Members who can't create events: suppress the broken behavior and do nothing.
    if (!currentUser.can_create_discourse_post_event) {
      return;
    }

    modal.show(QuickEventModal, {
      model: { startDate: cell.getAttribute("data-date") },
    });
  };

  // Capture phase so we run before FullCalendar's listeners on the calendar element.
  ["pointerdown", "mousedown", "mouseup", "click"].forEach((type) =>
    document.addEventListener(type, onCalendarPointer, true)
  );
});
