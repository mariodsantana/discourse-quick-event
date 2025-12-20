# Quick Event Creator - Discourse Theme Component

A Discourse theme component that adds a convenient header button for quickly creating events. Works seamlessly with the official **Discourse Calendar (and Event)** plugin.

## Features

- 📅 **Quick Access**: Adds an event creation button directly in the header
- 📝 **Simple Form**: Clean modal with all essential event fields
- 🔗 **Calendar Integration**: Events are created using the official Calendar plugin format
- ⚙️ **Configurable**: Customize category, default status, button icon, and more
- 📱 **Responsive**: Works on desktop and mobile

## Prerequisites

Before installing this theme component, ensure you have:

1. **Discourse Calendar (and Event) plugin** enabled
   - Go to Admin → Plugins → Calendar (and Event) → Enable
   - Enable `discourse post event enabled` in settings

2. **A category for events** configured in the Calendar plugin
   - Note the Category ID (found in category settings URL: `/c/{slug}/edit/general` - the ID is in the URL or shown in the interface)

## Installation

### Method 1: From Git Repository

1. Go to **Admin** → **Customize** → **Themes**
2. Click **Install** → **From a git repository**
3. Enter your repository URL
4. Click **Install**

### Method 2: Upload ZIP

1. Download this theme component as a ZIP file
2. Go to **Admin** → **Customize** → **Themes**
3. Click **Install** → **Upload**
4. Select the ZIP file

### Add to Active Theme

After installation:
1. Go to **Admin** → **Customize** → **Themes**
2. Select your active theme
3. Click **Include component**
4. Select **Quick Event Creator**

## Configuration

After installation, configure the component:

1. Go to **Admin** → **Customize** → **Themes**
2. Click on **Quick Event Creator** component
3. Click on **Settings**

### Required Settings

| Setting | Description |
|---------|-------------|
| `quick_event_category_id` | **REQUIRED**: The ID of the category where events will be created. Find this in the category's edit URL. |

### Optional Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `quick_event_default_status` | `public` | Default event status: `public`, `private`, or `standalone` |
| `quick_event_button_icon` | `calendar-plus` | Font Awesome icon name (without `fa-` prefix) |
| `quick_event_button_label` | `New Event` | Button text (leave empty for icon-only) |
| `quick_event_show_max_attendees` | `true` | Show the max attendees field in the form |

## Usage

1. Click the calendar button in the header (visible to logged-in users)
2. Fill in the event details:
   - **Title** (required): The event/topic title
   - **Description**: Event details and information
   - **Start date/time** (required): When the event begins
   - **End date/time**: When the event ends (optional)
   - **Max attendees**: Limit participants (optional)
3. Click **Create Event**
4. You'll be redirected to the new event topic

## Event Status Types

- **Public**: Anyone can RSVP to the event
- **Private**: Invite-only event
- **Standalone**: Event displays but no RSVP functionality

## Permissions

The button only appears for logged-in users. Event creation permissions are controlled by:
- The target category's posting permissions
- The Calendar plugin's `discourse post event allowed on groups` setting

## Troubleshooting

### Button doesn't appear
- Ensure the user is logged in
- Check that the theme component is included in your active theme

### "Please configure a category" error
- Set the `quick_event_category_id` in theme settings
- Use a valid category ID where the user has posting permissions

### Events not showing calendar features
- Verify the Calendar plugin is enabled
- Ensure `discourse post event enabled` is checked
- Confirm the category allows events

### Can't find Category ID
1. Go to the category you want to use
2. Click the edit/wrench icon → Settings
3. The ID is in the URL: `/c/your-category/edit/general` shows the slug
4. Or check the category API: `/categories.json`

## Technical Details

### Event Format
Events are created using the official Calendar plugin BBCode format:
```
[event name="Event Title" start="YYYY-MM-DD HH:mm" end="YYYY-MM-DD HH:mm" status="public" timezone="America/New_York" showLocalTime="true" maxAttendees="10"]
Event description goes here...

[/event]
```

The following attributes are included:
- `name` - The event title
- `start` - Start date/time
- `end` - End date/time (optional)
- `status` - Event status (public/private/standalone)
- `timezone` - Automatically detected from user's browser
- `showLocalTime` - Always set to true for better UX
- `maxAttendees` - Maximum attendees (optional, if configured)

### API Endpoint
Creates topics via `POST /posts` with the event markdown embedded in the post body.

### File Structure
```
discourse-quick-event/
├── about.json
├── settings.yml
├── locales/
│   └── en.yml
├── javascripts/
│   └── discourse/
│       ├── api-initializers/
│       │   └── add-quick-event-button.js
│       └── components/
│           ├── quick-event-button.gjs
│           └── modal/
│               └── quick-event-modal.gjs
└── stylesheets/
    └── quick-event.scss
```

## License

MIT License - Feel free to modify and distribute.

## Contributing

Contributions welcome! Please submit issues and pull requests.
