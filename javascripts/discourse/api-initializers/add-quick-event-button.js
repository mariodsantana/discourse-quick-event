import { apiInitializer } from "discourse/lib/api";
import QuickEventButton from "../components/quick-event-button";

export default apiInitializer("1.0", (api) => {
  const currentUser = api.getCurrentUser();
  
  // Only show if user is logged in
  if (!currentUser) {
    return;
  }

  api.headerIcons.add("quick-event-button", QuickEventButton);
});
