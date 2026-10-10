<script lang="ts">
	import GitHubIcon from '#lib/components/GitHubIcon.svelte';
</script>

<svelte:head>
	<title>Equipment Hire — engineering case study by Luuk Vlasblom</title>
	<meta
		name="description"
		content="How I designed and built a transactional equipment-hire application with Svelte, Go, PostgreSQL, sqlc, Atlas and Docker."
	/>
</svelte:head>

<main class="case-study">
	<header class="project-header">
		<div class="container header-grid">
			<div class="header-label">
				<p>Luuk Vlasblom / Portfolio case study</p>
				<p>Completed full-stack application · 2026</p>
			</div>

			<div class="project-introduction">
				<p class="eyebrow">Project overview</p>
				<h1>Equipment Hire</h1>
				<p class="lede">
					A full-stack equipment rental system built to explore transactional booking, physical
					inventory, staff workflows and production-minded delivery. This page documents the
					technical decisions and the parts that required the most work.
				</p>

				<nav class="primary-links" aria-label="Project links">
					<a class="demo-link" href="/home">Use the finished application <span>→</span></a>
					<a
						class="github-link"
						href="https://github.com/D3Duck/EquipmentTest"
						target="_blank"
						rel="noreferrer"><GitHubIcon /> <span>Read the source code ↗</span></a
					>
				</nav>
			</div>

			<dl class="project-ledger">
				<div>
					<dt>My role</dt>
					<dd>Design, backend, frontend and deployment</dd>
				</div>
				<div>
					<dt>Frontend</dt>
					<dd>Svelte 5, TypeScript, project-owned CSS</dd>
				</div>
				<div>
					<dt>Backend</dt>
					<dd>Go, Fiber, pgx and sqlc</dd>
				</div>
				<div>
					<dt>Data</dt>
					<dd>PostgreSQL 15 and Atlas migrations</dd>
				</div>
				<div>
					<dt>Operations</dt>
					<dd>Docker, Caddy, WebSockets and structured logs</dd>
				</div>
			</dl>
		</div>
	</header>

	<div class="container article-layout">
		<aside class="contents">
			<p>On this page</p>
			<nav aria-label="Case study sections">
				<a href="#brief"><span>01</span>The brief</a>
				<a href="#architecture"><span>02</span>Technical shape</a>
				<a href="#hard-parts"><span>03</span>The hard parts</a>
				<a href="#easy-parts"><span>04</span>The easier parts</a>
				<a href="#quality"><span>05</span>Quality and delivery</a>
				<a href="#retrospective"><span>06</span>Retrospective</a>
				<a href="#demo"><span>07</span>Explore it</a>
			</nav>
		</aside>

		<article class="article">
			<section id="brief" class="article-section opening-section">
				<p class="section-number">01 / The brief</p>
				<h2>Domain model</h2>
				<p class="large-copy">
					Customers hire “a circular saw”, but the shop owns three separately tracked saws. The
					customer cares about quantity and dates; staff care about asset numbers, maintenance,
					collection and return. I made that distinction the centre of the data model.
				</p>
				<div class="brief-columns">
					<div>
						<h3>Customer side</h3>
						<p>
							Search the catalogue, check a half-open hire period, build a basket, complete a
							simulated checkout, and manage bookings without seeing internal unit data.
						</p>
					</div>
					<div>
						<h3>Store side</h3>
						<p>
							Allocate physical units, process collections and returns, view customers, maintain
							assets, change prices, and resolve operational exceptions.
						</p>
					</div>
					<div>
						<h3>System side</h3>
						<p>
							Audit sensitive actions, manage demo access, monitor the shared environment, and reset
							it to deterministic seed data safely.
						</p>
					</div>
				</div>
			</section>

			<section id="architecture" class="article-section">
				<p class="section-number">02 / Technical shape</p>
				<h2>Architecture and technology choices</h2>
				<p>
					I kept it as a modular monolith. That gives the project real transaction boundaries and
					clear packages without adding queues and services that a single-depot application does not
					need.
				</p>

				<div class="architecture" aria-label="Application architecture">
					<div>
						<span>Browser</span><strong>Svelte 5 application</strong><small
							>typed API models · accessible states</small
						>
					</div>
					<i aria-hidden="true">HTTP + WebSocket ↓</i>
					<div>
						<span>Application</span><strong>Go / Fiber modular monolith</strong><small
							>authentication · catalogue · booking · operations</small
						>
					</div>
					<i aria-hidden="true">generated queries ↓</i>
					<div>
						<span>Persistence</span><strong>PostgreSQL + sqlc</strong><small
							>transactions · constraints · exclusion checks</small
						>
					</div>
				</div>

				<div class="stack-notes">
					<div>
						<code>Svelte 5</code>
						<p>
							Enough structure for a responsive application without hiding browser behaviour behind
							a large UI framework.
						</p>
					</div>
					<div>
						<code>Go + Fiber</code>
						<p>
							Simple request handling, predictable concurrency, fast builds and a small deployable
							binary.
						</p>
					</div>
					<div>
						<code>sqlc + pgx</code>
						<p>
							SQL stays visible and reviewable while Go receives generated, checked query methods
							instead of hand-written row scanning.
						</p>
					</div>
					<div>
						<code>Atlas</code>
						<p>
							The desired schema and immutable migration history are both kept in source control and
							checked during delivery.
						</p>
					</div>
				</div>
			</section>

			<section id="hard-parts" class="article-section">
				<p class="section-number">03 / The hard parts</p>
				<h2>Implementation challenges</h2>

				<div class="challenge-list">
					<section>
						<header>
							<span>01</span>
							<h3>Preventing double bookings</h3>
						</header>
						<p>
							A catalogue check is only advisory. At checkout I calculate availability again and
							create the booking inside one database transaction. Concurrent attempts contend on the
							same inventory; one succeeds and the other receives a useful conflict response.
						</p>
						<p class="implementation-note">
							<strong>Important detail:</strong> periods are <code>[start, end)</code>, so an item
							returned at 10:00 can be hired again from 10:00.
						</p>
					</section>

					<section>
						<header>
							<span>02</span>
							<h3>Separating capacity from allocation</h3>
						</header>
						<p>
							A booking reserves product capacity first. A specific physical unit can be allocated
							later and swapped before collection. Price and product text are snapshotted so old
							bookings remain historically accurate after catalogue edits.
						</p>
					</section>

					<section>
						<header>
							<span>03</span>
							<h3>Maintenance and operational state</h3>
						</header>
						<p>
							Availability is not just stock minus bookings. Retired units never contribute;
							maintenance removes a unit only where its maintenance period overlaps the requested
							hire. Returns and condition changes publish updated availability to connected clients.
						</p>
					</section>

					<section>
						<header>
							<span>04</span>
							<h3>Authorization that survives a modified client</h3>
						</header>
						<p>
							Employees can run the desk and view customer details. Store administrators
							additionally manage products, prices, units and maintenance. System administrators
							inherit everything and control the shared demo. Every rule is enforced by the API, not
							by hidden buttons.
						</p>
					</section>
				</div>
			</section>

			<section id="easy-parts" class="article-section">
				<p class="section-number">04 / The easier parts</p>
				<h2>Straightforward implementation work</h2>
				<div class="prose-grid">
					<div>
						<h3>The catalogue UI</h3>
						<p>
							Once the API returned a stable product shape, search, category filtering and sorting
							were ordinary derived client state. The visual work was mostly restraint: dense cards,
							small reference images and obvious hire controls.
						</p>
					</div>
					<div>
						<h3>Adding admin screens</h3>
						<p>
							The domain services and permissions did the difficult work. Product, unit and
							maintenance forms became thin interfaces over the same validation rules rather than
							separate logic.
						</p>
					</div>
					<div>
						<h3>Deployment</h3>
						<p>
							A multi-stage container builds the Svelte frontend and Go service. Caddy terminates
							TLS; PostgreSQL is private; health checks gate rollout. The application and database
							can be deployed independently when a migration is backward compatible.
						</p>
					</div>
				</div>
			</section>

			<section id="quality" class="article-section">
				<p class="section-number">05 / Quality and delivery</p>
				<h2>Testing and delivery</h2>
				<p>
					The highest-value tests run against PostgreSQL because availability and concurrency are
					database problems. Smaller service and handler tests keep validation failures fast to
					diagnose.
				</p>

				<ul class="test-list">
					<li><span>Intervals</span>Adjacent periods, exact boundaries and invalid ranges</li>
					<li><span>Concurrency</span>Two checkouts competing for the final available unit</li>
					<li>
						<span>Inventory</span>Maintenance overlap, retired units and replacement allocations
					</li>
					<li><span>Money</span>Price snapshots, changed-price review and integer-cent totals</li>
					<li>
						<span>Access</span>Customer ownership plus employee, store-admin and system-admin
						permissions
					</li>
					<li>
						<span>Operations</span>Migration validation, health checks, graceful shutdown and demo
						reset
					</li>
				</ul>

				<div class="delivery-line">
					<code>format</code><b>→</b><code>static analysis</code><b>→</b><code>unit tests</code><b
						>→</b
					><code>PostgreSQL integration</code><b>→</b><code>migration lint</code><b>→</b><code
						>container smoke test</code
					>
				</div>
			</section>

			<section id="retrospective" class="article-section">
				<p class="section-number">06 / Retrospective</p>
				<h2>Retrospective</h2>
				<div class="retrospective">
					<div>
						<h3>Keep</h3>
						<ul>
							<li>Modelling products and physical units separately from day one.</li>
							<li>Writing SQL deliberately and generating only the Go boundary around it.</li>
							<li>Using database constraints as a second line of defence.</li>
							<li>Making the demo reset deterministic instead of maintaining fragile fixtures.</li>
						</ul>
					</div>
					<div>
						<h3>Change next time</h3>
						<ul>
							<li>Define the API response types before building the first catalogue UI.</li>
							<li>Add browser-level accessibility tests earlier in the design cycle.</li>
							<li>Establish the audit vocabulary before implementing admin actions.</li>
							<li>Keep portfolio content separate from the store navigation sooner.</li>
						</ul>
					</div>
				</div>
			</section>

			<section id="demo" class="article-section demo-section">
				<p class="section-number">07 / Explore it</p>
				<h2>Run the demo</h2>
				<p>
					The shared demo contains customers, live and historical bookings, equipment in different
					operational states, scheduled maintenance and audit history. No real payment details are
					accepted or stored.
				</p>

				<div class="demo-actions">
					<a class="demo-link" href="/home">Start as a customer <span>→</span></a>
					<a href="/login">Use a staff demo account</a>
					<a
						class="github-link"
						href="https://github.com/D3Duck/EquipmentTest"
						target="_blank"
						rel="noreferrer"><GitHubIcon /> <span>Inspect the repository ↗</span></a
					>
				</div>
			</section>
		</article>
	</div>
</main>

<style>
	.case-study {
		background: var(--canvas);
	}
	.project-header {
		padding: 1.75rem 0 2rem;
		border-bottom: 1px solid var(--ink);
	}
	.header-grid {
		display: grid;
		grid-template-columns: minmax(0, 1fr) minmax(18rem, 22rem);
		gap: 1rem 3rem;
		align-items: start;
	}
	.header-label {
		display: flex;
		grid-column: 1 / -1;
		justify-content: space-between;
		gap: 1rem;
		padding-bottom: 0.55rem;
		border-bottom: 1px solid var(--line);
		color: var(--muted);
		font:
			0.7rem/1.5 ui-monospace,
			monospace;
		text-transform: uppercase;
	}
	.header-label p {
		margin: 0;
	}
	.eyebrow,
	.section-number,
	.contents > p {
		margin: 0 0 0.65rem;
		color: var(--brand-dark);
		font:
			700 0.72rem/1.4 ui-monospace,
			monospace;
		letter-spacing: 0.04em;
		text-transform: uppercase;
	}
	h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(1.9rem, 3vw, 2.5rem);
		font-weight: 720;
		letter-spacing: -0.035em;
		line-height: 1.08;
	}
	.lede {
		max-width: 44rem;
		margin: 0.75rem 0 0;
		color: var(--text);
		font-size: 0.94rem;
		line-height: 1.55;
	}
	.primary-links,
	.demo-actions {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: 0.65rem 1.2rem;
		margin-top: 1rem;
	}
	.primary-links a,
	.demo-actions a {
		color: var(--ink);
		font-size: 0.82rem;
		font-weight: 700;
		text-underline-offset: 0.25rem;
	}
	.github-link {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
	}
	.demo-link {
		display: inline-flex;
		min-height: 2.35rem;
		align-items: center;
		gap: 1.25rem;
		padding: 0.4rem 0.7rem;
		border: 1px solid var(--line-dark);
		color: var(--ink) !important;
		text-decoration: none;
	}
	.demo-link:hover {
		border-color: var(--ink);
		background: var(--surface);
	}
	.project-ledger {
		margin: 0;
		border-top: 1px solid var(--ink);
	}
	.project-ledger div {
		padding: 0.5rem 0;
		border-bottom: 1px solid var(--line);
	}
	.project-ledger dt {
		color: var(--muted);
		font-size: 0.68rem;
		text-transform: uppercase;
	}
	.project-ledger dd {
		margin: 0.2rem 0 0;
		color: var(--ink);
		font-size: 0.82rem;
		font-weight: 650;
	}
	.article-layout {
		display: grid;
		grid-template-columns: 10rem minmax(0, 1fr);
		gap: 2.5rem;
	}
	.contents {
		position: sticky;
		top: 8rem;
		align-self: start;
		padding-top: 2rem;
	}
	.contents nav {
		display: grid;
		border-top: 1px solid var(--line-dark);
	}
	.contents a {
		display: grid;
		grid-template-columns: 1.6rem 1fr;
		gap: 0.35rem;
		padding: 0.65rem 0;
		border-bottom: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.72rem;
		line-height: 1.3;
		text-decoration: none;
	}
	.contents a:hover {
		color: var(--brand-dark);
	}
	.contents a span {
		font-family: ui-monospace, monospace;
	}
	.article {
		min-width: 0;
		border-left: 1px solid var(--line);
	}
	.article-section {
		max-width: 68rem;
		padding: 2.25rem 0 2.5rem 2.5rem;
		scroll-margin-top: 7rem;
	}
	.article-section + .article-section {
		border-top: 1px solid var(--line-dark);
	}
	.article-section h2 {
		max-width: 32ch;
		margin: 0;
		color: var(--ink);
		font-size: clamp(1.4rem, 2.2vw, 1.8rem);
		letter-spacing: -0.025em;
		line-height: 1.2;
	}
	.article-section > p:not(.section-number) {
		max-width: 48rem;
		color: var(--muted);
		font-size: 0.88rem;
		line-height: 1.6;
	}
	.article-section .large-copy {
		color: var(--text) !important;
		font-size: 0.94rem;
	}
	.brief-columns,
	.prose-grid {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 0;
		margin-top: 1.5rem;
		border-top: 1px solid var(--ink);
	}
	.brief-columns > div,
	.prose-grid > div {
		padding: 0.9rem 1rem 0 0;
	}
	.brief-columns > div + div,
	.prose-grid > div + div {
		padding-left: 1rem;
		border-left: 1px solid var(--line);
	}
	h3 {
		margin: 0;
		color: var(--ink);
		font-size: 0.95rem;
	}
	.brief-columns p,
	.prose-grid p {
		margin: 0.55rem 0 0;
		color: var(--muted);
		font-size: 0.83rem;
		line-height: 1.65;
	}
	.architecture {
		display: grid;
		grid-template-columns: 1fr 8rem 1fr 8rem 1fr;
		align-items: center;
		margin-top: 1.5rem;
		padding: 0.9rem;
		border: 1px solid var(--line-dark);
		background: var(--surface);
	}
	.architecture div {
		display: grid;
		gap: 0.25rem;
	}
	.architecture span {
		color: var(--brand-dark);
		font:
			700 0.68rem ui-monospace,
			monospace;
		text-transform: uppercase;
	}
	.architecture strong {
		color: var(--ink);
		font-size: 0.87rem;
	}
	.architecture small {
		color: var(--muted);
		font-size: 0.68rem;
		line-height: 1.4;
	}
	.architecture i {
		color: var(--muted);
		font:
			normal 0.66rem ui-monospace,
			monospace;
		text-align: center;
	}
	.stack-notes {
		margin-top: 1.25rem;
		border-top: 1px solid var(--ink);
	}
	.stack-notes > div {
		display: grid;
		grid-template-columns: 9rem 1fr;
		gap: 1rem;
		padding: 0.85rem 0;
		border-bottom: 1px solid var(--line);
	}
	.stack-notes code,
	.implementation-note code,
	.delivery-line code {
		color: var(--brand-dark);
		font-size: 0.78rem;
		font-weight: 700;
	}
	.stack-notes p {
		margin: 0;
		color: var(--muted);
		font-size: 0.82rem;
		line-height: 1.55;
	}
	.challenge-list {
		margin-top: 1.5rem;
		border-top: 1px solid var(--ink);
	}
	.challenge-list > section {
		display: grid;
		grid-template-columns: minmax(13rem, 0.65fr) 1fr;
		gap: 1.5rem;
		padding: 1rem 0;
		border-bottom: 1px solid var(--line);
	}
	.challenge-list header {
		display: grid;
		grid-template-columns: 2rem 1fr;
		gap: 0.5rem;
	}
	.challenge-list header span {
		color: var(--brand-dark);
		font:
			0.7rem ui-monospace,
			monospace;
	}
	.challenge-list p {
		margin: 0;
		color: var(--muted);
		font-size: 0.88rem;
		line-height: 1.65;
	}
	.challenge-list .implementation-note {
		grid-column: 2;
		margin-top: -0.7rem;
		padding: 0.75rem;
		border-left: 3px solid var(--brand);
		background: var(--surface);
		font-size: 0.76rem;
	}
	.test-list {
		margin: 1.5rem 0 0;
		padding: 0;
		border-top: 1px solid var(--ink);
		list-style: none;
	}
	.test-list li {
		display: grid;
		grid-template-columns: 9rem 1fr;
		gap: 1rem;
		padding: 0.85rem 0;
		border-bottom: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.84rem;
	}
	.test-list span {
		color: var(--ink);
		font-weight: 700;
	}
	.delivery-line {
		display: flex;
		flex-wrap: wrap;
		gap: 0.6rem;
		margin-top: 1.25rem;
		padding: 0.75rem;
		border: 1px solid var(--line-dark);
		background: var(--surface);
	}
	.delivery-line b {
		color: var(--muted);
		font-weight: 400;
	}
	.retrospective {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 2rem;
		margin-top: 1.5rem;
	}
	.retrospective > div {
		border-top: 1px solid var(--ink);
		padding-top: 1rem;
	}
	.retrospective ul {
		margin: 1rem 0 0;
		padding-left: 1rem;
		color: var(--muted);
		font-size: 0.85rem;
		line-height: 1.65;
	}
	.retrospective li + li {
		margin-top: 0.5rem;
	}
	.demo-section {
		padding-bottom: 3rem;
	}
	@media (max-width: 1000px) {
		.header-grid {
			grid-template-columns: minmax(0, 1fr) 18rem;
		}
		.article-layout {
			grid-template-columns: 7rem minmax(0, 1fr);
		}
		.architecture {
			grid-template-columns: 1fr;
			gap: 0.7rem;
		}
		.architecture i {
			text-align: left;
		}
	}
	@media (max-width: 760px) {
		.header-grid {
			grid-template-columns: 1fr;
		}
		.header-label {
			grid-column: auto;
		}
		.project-ledger {
			grid-column: auto;
		}
		.article-layout {
			display: block;
		}
		.contents {
			position: static;
			padding: 1.5rem 0;
			border-bottom: 1px solid var(--line-dark);
		}
		.contents > p {
			margin-bottom: 0.5rem;
		}
		.contents nav {
			grid-template-columns: 1fr 1fr;
		}
		.contents a {
			padding-right: 0.5rem;
		}
		.article {
			border-left: 0;
		}
		.article-section {
			padding-left: 0;
		}
		.brief-columns,
		.prose-grid {
			grid-template-columns: 1fr;
		}
		.brief-columns > div,
		.prose-grid > div,
		.brief-columns > div + div,
		.prose-grid > div + div {
			padding: 1rem 0;
			border-left: 0;
			border-bottom: 1px solid var(--line);
		}
		.challenge-list > section {
			grid-template-columns: 1fr;
			gap: 0.8rem;
		}
		.challenge-list .implementation-note {
			grid-column: auto;
			margin-top: 0;
		}
	}
	@media (max-width: 520px) {
		.project-header {
			padding-top: 1.25rem;
		}
		h1 {
			font-size: 1.9rem;
		}
		.header-label {
			display: block;
		}
		.contents nav {
			grid-template-columns: 1fr;
		}
		.stack-notes > div,
		.test-list li {
			grid-template-columns: 1fr;
			gap: 0.35rem;
		}
		.retrospective {
			grid-template-columns: 1fr;
			gap: 2rem;
		}
		.demo-actions {
			align-items: stretch;
			flex-direction: column;
		}
		.demo-actions a {
			width: fit-content;
		}
	}
</style>
