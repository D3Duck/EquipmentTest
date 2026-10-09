# Equipment Hire Portfolio App

A practical equipment-hire application built as a portfolio project. It should demonstrate production-minded application development, including transactional booking logic, role-based access, real-time updates, automated testing, deployment, and observability.

## Product Scope

The application lets customers browse equipment, select a hire period and quantity, complete a simulated checkout, and manage their bookings. Store administrators manage catalogue listings, physical equipment units, prices, maintenance, and booking fulfilment. System administrators manage the shared demo environment and can inspect audit information.

The initial product is solely an equipment-hire application. Uptime-monitor features and data are not part of its domain.

### Initial Constraints

- Use a small but varied catalogue with enough dummy data to demonstrate every workflow and state.
- Do not support public registration, real payments, email notifications, refunds, or advanced business reporting initially.
- Customers request a product and quantity; they do not choose individual physical units.
- Store administrators allocate physical units automatically or manually before collection.
- The interface must be responsive and support light and dark themes.
- Use lightweight project-owned CSS with reusable design tokens and components; do not depend on a CSS framework.

## Roles and Permissions

| Capability                                       | Customer | Store administrator | System administrator |
| ------------------------------------------------ | -------- | ------------------- | -------------------- |
| Browse equipment and availability                | Yes      | Yes                 | Yes                  |
| Create and view own bookings                     | Yes      | No                  | No                   |
| Cancel own eligible bookings                     | Yes      | No                  | No                   |
| Manage catalogue, units, prices, and maintenance | No       | Yes                 | No                   |
| View and fulfil all bookings                     | No       | Yes                 | No                   |
| View demo access and audit information           | No       | No                  | Yes                  |
| Reset the demo environment                       | No       | No                  | Yes                  |

Demo accounts:

- `customer1` and `customer2`
- `storeadmin`
- `admin`

Server-side authorization is authoritative for every protected action. Hiding a control in the user interface is not considered sufficient access control.

## Shared Layout and Demo Access

### Navigation

- Home
- Equipment
- Cart
- My Bookings for customers
- Store Management for store administrators
- System Administration for system administrators
- GitHub repository
- Current demo account and sign-out action

### Footer

- Built by Luuk Vlasblom
- Stack: Svelte 5, Go, Fiber, PostgreSQL, Atlas, Docker, and Caddy
- Source-code link

### Sign-in and Demo Reset

- First-time visitors arrive at the portfolio overview and can enter the customer demo without signing in.
- The dedicated sign-in page is linked from the global navigation and portfolio overview.
- Demo credentials are displayed clearly below the form.
- The seeded database includes catalogue products, physical units, customers, bookings, maintenance records, and audit events covering all important states.
- Only the system administrator can trigger **Reset Demo**.
- Resetting requires confirmation, runs as one controlled server-side operation, and restores a predefined dataset.
- While a reset is running, writes are temporarily rejected and users receive a clear message. Connected clients are prompted to reload after completion.
- Reset actions are recorded in the audit log. The interface warns that other users' demo changes will be removed.

## Customer Workflows

### Portfolio Overview — `/`

- Explain the purpose and current scope of the portfolio project for prospective employers.
- Link to the source repository.
- Summarize the architecture, deployment, and notable implementation decisions.
- Explain how to explore the public demo.

### Customer Home — `/home`

- Explain the equipment-hire and depot-collection workflow.
- Provide a clear **Browse Equipment** call to action.

### Equipment Catalogue — `/equipment`

- Search by name or description and filter by category.
- Select a start and end date/time.
- Display one card per equipment product, including:
  - Image
  - Name
  - Category
  - Short description
  - Unit price
  - Quantity available for the selected period
- Allow customers to open a product detail page.
- Availability updates when the selected period changes or another customer completes a booking.

### Equipment Details — `/equipment/products/:id`

- Show images, description, specifications, price, and hire terms.
- Let the customer select a hire period and quantity.
- Show availability for the selected period without exposing another customer's details.
- Add the requested product, quantity, period, and current quoted price to the basket.
- Display clear validation and availability errors.

### Cart — `/cart`

- Show all requested products, quantities, periods, unit prices, and totals.
- Each basket item has its own hire period; changing a period revalidates that basket line.
- Allow quantity changes and removal before checkout.
- A basket does not reserve inventory.
- Clearly state that availability and current prices will be checked again during checkout.

### Simulated Checkout — `/checkout`

- Label the page prominently as a simulation; no real payment data is collected, transmitted, or stored.
- Use obviously fictional, pre-filled payment details.
- **Pay Now** rechecks price and availability and then creates the booking in one database transaction.
- If inventory or a price changed, do not create a partial booking. Return the customer to a review state with a clear explanation.
- On success, show a booking confirmation and clear the purchased basket lines.

### Booking Confirmation — `/checkout/confirmation`

- Confirm that the simulated checkout completed and show the booking reference.
- Summarize booked items, hire periods, totals, and depot collection details.
- Link to the persistent booking detail and customer booking history.

### My Bookings — `/bookings`

- Separate upcoming/current and past bookings.
- Show the booking reference, products, quantities, allocated units when applicable, hire period, total, and status.
- Customers may cancel a `reserved` booking until its start time.
- A booking cannot be customer-cancelled after collection or after its start time; a store administrator must resolve it.
- Cancellation releases the reserved capacity immediately and creates an audit event.

### Booking Details — `/bookings/:id`

- Show one customer-owned booking with its item, price, allocation, period, and status history.
- Expose eligible customer cancellation without revealing another customer's information.

## Store Management Workflows

Store-administrator workflows use the `/store` workspace. The operational schedule and fulfilment
pages represent depot employee work without introducing a separate authorization role.

- `/store` — operational overview.
- `/store/schedule` — collections, returns, overdue items, and conflicts.
- `/store/bookings` and `/store/bookings/:id` — booking fulfilment and unit allocation.
- `/store/inventory` — catalogue products and physical units.
- `/store/inventory/products/:id` — product administration.
- `/store/inventory/units/:id` — physical-unit state and history.
- `/store/maintenance` — active, planned, and historical maintenance.

### Catalogue and Inventory

- Add and edit products, including descriptions, categories, images, prices, and visibility.
- Add and edit physical units with a unique asset number.
- Mark a unit as available, in maintenance, or retired.
- Maintenance and retired units are excluded from availability calculations.
- Price, operational-state, and allocation changes create audit events.

### Booking Fulfilment

- View and filter all bookings.
- Allocate suitable physical units to booked quantities without double allocation.
- Move booking items through `reserved`, `collected`, `returned`, or `cancelled` states.
- Treat a collected item whose end time has passed as overdue until it is returned.
- Allow an administrator to record an exceptional cancellation after the normal customer cancellation deadline, including a reason.

## System Administration

System-administrator workflows use the `/system` workspace:

- `/system` — system-administration overview.
- `/system/audit` — audit events.
- `/system/access` — safe demo identity, role, session, and sign-in information.
- `/system/demo` — protected demo reset.

- View sign-in and important demo activity without exposing passwords or sensitive authentication data.
- View the audit log, including actor, action, affected entity, timestamp, and relevant before/after values.
- Trigger the protected demo reset workflow.

## Domain and Data Model

### Main Entities

- `users`: demo identities and roles.
- `equipment_products`: customer-facing catalogue entries such as “Makita Cordless Drill.”
- `equipment_units`: individually tracked physical assets belonging to a product.
- `maintenance_records`: periods during which a unit cannot be hired.
- `baskets` and `basket_items`: unreserved customer selections.
- `bookings`: customer, total, and overall lifecycle information.
- `booking_items`: booked product, quantity, hire period, and price snapshot.
- `booking_item_units`: changeable physical-unit allocations made before collection.
- `audit_events`: security- and business-relevant changes.

### Status Model

Operational state belongs to a physical unit:

- `available`
- `maintenance`
- `retired`

Fulfilment state belongs to a booking item:

- `reserved`
- `collected`
- `returned`
- `cancelled`

`Overdue` is derived when an item is still collected after that item's hire end time; it is not stored as a physical-unit state. Whether a unit is available for a future period is calculated from its operational state, maintenance periods, active bookings, and allocations.

### Booking and Availability Rules

- Hire periods use half-open intervals: `[start, end)`. A booking ending at 12:00 does not overlap one beginning at 12:00.
- End time must be later than start time.
- Start and end times are stored in UTC. The interface displays the user's selected or configured local timezone and labels it clearly.
- An active booking is one that has not been cancelled.
- Requested quantity must be positive and cannot exceed the available quantity for the complete hire period.
- Availability is checked when browsing and checked again during checkout.
- Checkout uses a database transaction and database-level concurrency protection so simultaneous customers cannot overbook stock.
- Booking creation and simulated payment success are atomic: either every basket line is booked or none are.
- Cancelling a booking releases its capacity immediately.
- Historical booking items retain the price charged even if the catalogue price later changes.
- Allocation cannot assign the same physical unit to overlapping active bookings or a maintenance period.

## Real-Time Behaviour

Use WebSockets to send compact invalidation events; clients refetch authoritative data after receiving them.

- `availability_changed`: refresh affected product availability after checkout, cancellation, maintenance, or reset.
- `price_changed`: refresh the affected product and warn users reviewing an older basket price.
- `booking_changed`: refresh the affected customer's booking view.
- `demo_reset`: notify all connected users and prompt them to reload.

Show a bottom-right notification when another user's action changes availability or price. Notifications remain visible long enough to demonstrate the behaviour and can be dismissed.

## Architecture and Operations

- Svelte 5 provides the frontend.
- Go with Fiber serves the JSON API, WebSocket endpoint, and built frontend.
- PostgreSQL stores application data and enforces critical booking invariants.
- Atlas manages versioned database migrations.
- Docker Compose runs the application services locally and in suitable deployment environments.
- Caddy handles public HTTPS where it is part of the selected hosting architecture.
- Secrets and environment-specific configuration stay outside source control.
- Structured logs include request or correlation IDs without logging credentials or simulated payment fields.
- A health endpoint reports application readiness without exposing sensitive details.
- Persistent application data survives service restarts.

## Delivery Phases

### Phase 1 — Core MVP

- Demo authentication and role-based authorization
- Seeded catalogue and physical-unit inventory
- Period- and quantity-aware availability
- Basket and atomic simulated checkout
- Customer booking history and eligible cancellation
- Store catalogue, maintenance, and booking management
- Database migrations and concurrency tests

### Phase 2 — Portfolio Polish

- WebSocket invalidation and notifications
- Physical-unit allocation and complete collection/return workflow
- Overdue presentation
- Audit log and protected demo reset
- Responsive design, accessibility pass, and light/dark themes
- More comprehensive end-to-end tests

### Phase 3 — Infrastructure Showcase

- Automated build, tests, migrations, and deployment
- Primary deployment with custom domain, DNS, and HTTPS
- Health checks, structured logs, and basic operational dashboards
- Infrastructure and cleanup documentation
- Reproduce the deployment on a second cloud only after the primary deployment is stable; target Azure and AWS to demonstrate portability

## Acceptance Criteria

The application is ready to demonstrate when all of the following are true:

- A customer can sign in, select a period and quantity, complete simulated checkout, and see the confirmed booking.
- Catalogue availability represents product quantities while the store can track individual physical units.
- Two concurrent checkout attempts for the final available unit result in exactly one successful booking.
- Back-to-back bookings succeed, while genuinely overlapping bookings cannot exceed capacity.
- Cancelling an eligible booking immediately restores availability.
- Units in maintenance or retired state are never offered as available.
- A unit cannot be allocated to overlapping bookings.
- Store and system administration endpoints reject unauthorized roles on the server.
- Price changes do not alter historical booking totals and are surfaced to customers before checkout.
- Collection, return, and overdue behaviour is visible and auditable.
- No real card information is requested, transmitted, or stored.
- Demo reset restores the predefined dataset safely and prompts connected users to reload.
- Loading, empty, success, validation, conflict, unauthorized, and server-error states are handled consistently.
- Data persists after an application restart, and migrations work from a clean database.
- Automated tests cover booking concurrency, interval boundaries, cancellation, permissions, price changes, maintenance exclusion, and reset behaviour.
- The deployed application uses HTTPS, keeps secrets out of source control, exposes a useful health check, and produces useful logs.

## Documentation Deliverables

- Local setup and demo-account instructions
- Architecture and domain-model overview
- API and WebSocket event documentation
- Explanation of transaction and concurrency choices
- Deployment, migration, rollback, backup, and resource-cleanup instructions
- A short interviewer walkthrough highlighting quantity-aware booking, database protection, real-time updates, authorization, and cloud deployment
