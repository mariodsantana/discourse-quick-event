import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.0", (api) => {
  const currentUser = api.getCurrentUser();
  
  // Only show if user is logged in
  if (!currentUser) {
    return;
  }

  api.addToHeaderIcons("quick-event-button");
});
