# Storefront Design Specification

## Direction

The storefront uses a restrained **Depot Ledger** design language: practical, precise, and visibly connected to physical inventory. Product discovery and rental context take priority over marketing presentation.

The design combines three reference strengths without reproducing their visual styling:

- McMaster-Carr's category-first information architecture and specification-led product selection.
- B&H's clear relationship between product information, price, stock, and action.
- Linear's disciplined alignment, compact application chrome, and consistent hierarchy.

The frontend remains Svelte 5, TypeScript, and project-owned CSS. Bootstrap and other UI frameworks are not used.

## Principles

- Put product, price, stock, and hire-period information before promotional content.
- Use alignment and fine separators for hierarchy instead of shadows and collections of floating cards.
- Reserve the accent colour for selection, focus, and primary actions.
- Keep storefront claims tied to implemented data. The portfolio case study is written from the
  completed-project perspective so it describes the intended finished system during development.
- Keep controls compact while preserving 44px touch targets and clear keyboard focus.
- Use the same spacing, typography, borders, and state language across every customer-facing route.

## Colour Tokens

| Token         | Value     | Purpose                                |
| ------------- | --------- | -------------------------------------- |
| Canvas        | `#f3f1ea` | Main warm-neutral page background      |
| Surface       | `#fcfbf7` | Controls and primary content surfaces  |
| Surface muted | `#e8e7e0` | Secondary regions and hover states     |
| Ink           | `#1c211f` | Headings and primary text              |
| Text          | `#303633` | Body text                              |
| Muted         | `#5e6661` | Supporting copy and metadata           |
| Border        | `#c8ccc6` | Standard separators                    |
| Border strong | `#858c87` | Controls and major divisions           |
| Oxide         | `#c84a2f` | Primary action and selection           |
| Oxide dark    | `#b33e25` | Hover and active action                |
| Oxide soft    | `#f2ded7` | Selected and focus-adjacent background |
| Available     | `#267048` | Positive stock state                   |
| Warning       | `#9b5b13` | Low-stock state                        |
| Danger        | `#a33a32` | Errors and unavailable state           |

Semantic colours support meaning but are never the only signal.

## Typography

- Body: system sans-serif, `15px / 22px`, weight 400.
- Controls and navigation: `14px / 20px`, weight 600.
- Metadata: `12px / 16px`.
- Product names: `17px / 22px`, weight 650.
- Section headings: `24px / 30px`.
- Page headings: `34px / 38px`, reduced to 30px on small screens.
- Prices, dates, and quantities use tabular numerals.
- Monospace is reserved for genuine product and asset identifiers.

## Spacing and Dimensions

- Base unit: 4px.
- Working scale: 4, 8, 12, 16, 24, 32, and 48px.
- Maximum storefront width: 1440px.
- Desktop gutters: 24-32px; mobile gutters: 16px.
- Standard control height: 42px; primary touch targets: at least 44px.
- Corners: 2px for controls and 4px for major functional panels.
- Borders: 1px. Shadows are reserved for overlays.

## Navigation

The header has two compact levels:

1. A service rail containing depot context and portfolio/source links.
2. The customer-store header containing the E/H mark, Home, Equipment, catalogue search, and sign-in.

The wordmark returns to the customer home. Portfolio navigation is deliberately secondary so the
store remains the primary product. Equipment, customer bookings, cart, and sign-in form the customer
navigation. Store Operations, Catalogue Administration, and System Administration remain secondary
until role-aware navigation is implemented.

## Portfolio Overview

The root route is an employer-facing engineering case study, separate from the customer storefront.
It uses a compact technical-document layout rather than a marketing hero or feature cards. Heading
sizes and section spacing stay close to README/documentation conventions. It explains the problem
model, architecture, technology choices, difficult and straightforward implementation work, testing,
delivery, and retrospective lessons in the first person. Links into the working demo and source
repository remain visible without dominating the technical account.

## Product Catalogue

The catalogue consists of:

- A compact page introduction.
- Hire-window context carried from the customer home without claiming date-aware availability.
- A category index with product counts and an oxide selection rule.
- Search, sort, result count, and clear-filter controls in one aligned toolbar.
- A dense product grid separated by rules rather than floating cards.

Product entries present information in this order:

1. Complete, uncropped product image.
2. Category and asset code.
3. Product name.
4. Daily rate.
5. Current demo-stock quantity.

Descriptions and specifications belong on the product detail page so the catalogue can remain dense
and scannable. No placeholder specifications are invented.

## Product Detail Direction

The product detail page uses a two-column layout with compact reference imagery on the left and a
dominant rental configuration area on the right. The configuration order is rate, dates, quantity,
availability response, and estimate.
Specifications use a technical two-column table. Hire terms remain structured text rather than
decorative panels. Basket actions remain explicitly unavailable until the basket API is implemented.

## Signature Decisions

1. **Hire-window rail:** dates and depot context remain visible while browsing.
2. **Category index:** a numbered catalogue index replaces filter pills.
3. **Specification ledger:** codes, rates, quantities, and later technical attributes use stable alignment and tabular numerals.

## Responsive and State Rules

- Wide desktop uses a category rail and five product columns, reducing to four and then three as the
  viewport narrows.
- Tablet uses two product columns with filters above the results.
- Mobile uses one column and an expandable category control.
- Long names wrap without changing the rate and stock alignment.
- Empty search retains the current controls and provides a reset action.
- Loading, image-failure, unavailable, validation, and server-error states must remain visually distinct when their data sources are implemented.
- Search-result changes use an `aria-live` result count.
- Hover is never the only interaction signal, and reduced-motion preferences are respected.

## Current Implementation Boundary

The catalogue and product detail pages load the public catalogue API. When a valid hire window is
present, quantities are period-qualified availability; without one, they represent currently
operational stock. Both pages keep loading, empty, validation, and server-error states explicit.

The remaining workflow routes exist as plain developer placeholders:

- Customer: cart, checkout, confirmation, booking list, and booking detail.
- Store operations: employee schedule and fulfilment, plus store-admin inventory, product, physical
  unit, price, and maintenance management.
- System administration: audit events, access, and protected demo reset.
- Shared states: access denied and the application error page.

These routes intentionally contain only an unstyled heading and TODO text. They are implementation markers, not previews of their eventual interfaces, and must not imply that a server mutation succeeded. They are replaced incrementally as the corresponding APIs and authorization rules are implemented.
