
# Cloud Portfolio App

A website demonstrating a practical application: an equipment hire system. This is intended to be used as a demo/portfolio app showing my capabilities to potential employers.

This document may have some old "uptime monitor" data. This is obsolete and can be ignored or removed.

## Shared Layout

### General points
- Clean UI. It should look how an equipment rental site would look.
- Light/Dark mode
- use Bootstrap for the css, with any adjustments
- Mobile friendly design
- Dummy data should be sufficient to allow easy showing of all parts of the app.

### Navigation Bar
- Home
- Equipment Hire
- GitHub repository link
- Demo account / Sign out

### Footer
- Built by Luuk Vlasblom
- Stack: Svelte 5, Go, PostgreSQL, Docker (with Fiber, Atlas and Bootstrap)
- Source code link (actual link to be set up later)

### Demo Access
- First load redirects to a home page with al log in screen. The log in credentials are listed cleanly underneath. There is a "customer1" and "customer2" accounts, a "storeadmin" account that can change equipment details and prices and an "admin" account which monitors app access.
- Demo contains sample monitors, equipment, and bookings.
- Show a "reset demo" button on the home page which resets the database to a pre-defined setup.

## Home — `/`

### Introduction
- Brief explanation of the website and its two applications.
- Link to source code.

### Equipment Hire Card
- Explain that it manages equipment availability and reservations.
- Instructions:
  1. Browse equipment.
  2. Choose a hire period.
  3. Make a booking and view it under My Bookings.
- “Open Equipment Hire” button.

### About the Project
- Short description of the architecture.
- Deployment information: hosting provider, DNS, and HTTPS.
- Brief explanation of notable implementation decisions.

## Equipment Hire — `/equipment`

### Equipment Catalogue
- Search and category filter.
- Equipment cards:
  - Image
  - Name
  - Category
  - Short description
- Start and end date/time filters.
- Availability shown for the selected period.
- “View Equipment” button.

### Equipment Details — `/equipment/items/:id`
- Image and description.
- Equipment information.
- Start and end date/time selection.
- Existing bookings / availability calendar.
- “Book Equipment” button.
- Booking confirmation or a clear availability error.

### My Bookings — `/equipment/bookings`
- Upcoming and past bookings.
- Equipment name.
- Hire period.
- Booking status.
- Cancel an upcoming booking.

### Booking Rules
- Each catalogue entry represents one physical equipment item.
- Multiple items of the same kind show once in the catalogue, but can be hired more than one at the time. This needs to be a specific feature to show to job interviewers. E.g. the app says "Only X of that item are available for the selected time period".
- End time must be after start time.
- Prevent overlapping active bookings in PostgreSQL.
- Recheck availability when submitting a booking.
- Back-to-back bookings are allowed.
- Cancelled bookings release their time slots.
- Equipment should have a status, visible to the admins, showing whether the equipment is booked, currently rented out, returned or overdue to be returned by the client.

### Payments
- Show a "basket" page with all the persons items they selected to rent.
- Then go to a payment page with fake pre-filled credit card data. "Pay now" always says success and reserves the items for the person that is signed in.

### Equipment Management
- Owner can add and edit equipment.
- Owner can mark equipment unavailable for maintenance.
- Owner can view all bookings.
- Management actions are restricted to the owner account.

### Websocket
- Users are notified when an item is rented out by another with a notification in the bottom right of the screen. Make it sticky for demo purposes.
- Available quantities change with bookings.
- When the admin changes a price, it updates on the user end as well.

## Backend and Data

### Application
- Go serves the built Svelte frontend and JSON API.
- PostgreSQL stores application data.
- Caddy handles public HTTPS.
- Docker Compose runs the services.
- Database migrations define and update the schema.

### Main Data
- Users
- Monitors
- Monitor checks
- Monitor incidents
- Equipment items
- Equipment bookings

### Shared Behaviour
- Server-side validation and permission checks.
- Consistent loading, empty, success, and error states.
- Store timestamps in UTC and display the applicable timezone.
- Persistent data survives application restarts.

## Deployment and Verification

- Deploy the same application to Azure and AWS.
- Connect a custom domain and enable HTTPS.
- Configure secrets outside source control.
- Provide a health endpoint and useful application logs.
- Automate build, tests, and deployment.
- Test:
  - Outage detection and recovery. The user admin should be able to see a graph with app uptime.
  - Concurrent attempts to book the same equipment.
  - Cancellation releasing availability.
  - Permission restrictions.
  - Data persistence after restart.
- Document deployment and resource cleanup.

## Initial Scope

- A small equipment catalogue.
- Owner manages data; visitors try the main workflows.
- No email notifications, registration, or advanced administration yet. Only admin accounts and store admin accounts.
