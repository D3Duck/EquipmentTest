<svelte:head>
	<title>Equipment Hire · Portfolio project by Luuk Vlasblom</title>
	<meta
		name="description"
		content="A production-minded equipment-hire portfolio application built with Svelte, Go and PostgreSQL."
	/>
</svelte:head>

<section class="portfolio-hero">
	<div class="container hero-layout">
		<div>
			<p class="project-byline">A portfolio project by Luuk Vlasblom</p>
			<h1>A booking system built around real inventory.</h1>
			<p class="hero-summary">
				Equipment Hire is a full-stack application for reserving hire products while staff manage
				the individual physical units behind them. It is designed to demonstrate careful domain
				modelling, transactional booking and production-minded delivery—not only a polished UI.
			</p>
			<div class="hero-actions">
				<a class="primary-action" href="/home">Open the customer demo</a>
				<a
					class="secondary-action"
					href="https://github.com/D3Duck/EquipmentTest"
					target="_blank"
					rel="noreferrer">View the source</a
				>
			</div>
		</div>

		<div class="project-facts" aria-label="Project technology and scope">
			<div><span>Frontend</span><strong>Svelte 5 + TypeScript</strong></div>
			<div><span>Backend</span><strong>Go + Fiber</strong></div>
			<div><span>Data</span><strong>PostgreSQL + Atlas</strong></div>
			<div><span>Delivery</span><strong>Docker-based deployment</strong></div>
		</div>
	</div>
</section>

<section class="section demo-section">
	<div class="container split-layout">
		<div class="section-heading">
			<h2>Explore the application</h2>
			<p>
				The public demo can be explored without signing in. Start with the customer experience, then
				inspect the catalogue and authentication flow.
			</p>
		</div>

		<ol class="demo-routes">
			<li>
				<span>01</span>
				<div>
					<h3>Start at the hire desk</h3>
					<p>
						See the customer-facing entry point, availability controls and collection information.
					</p>
					<a href="/home">Open customer home</a>
				</div>
			</li>
			<li>
				<span>02</span>
				<div>
					<h3>Browse the catalogue</h3>
					<p>
						Review realistic stock, daily rates, asset codes and responsive product presentation.
					</p>
					<a href="/equipment">Browse equipment</a>
				</div>
			</li>
			<li>
				<span>03</span>
				<div>
					<h3>Review the sign-in flow</h3>
					<p>See the customer authentication interface and its validation and failure states.</p>
					<a href="/login">Open sign in</a>
				</div>
			</li>
		</ol>
	</div>
</section>

<section class="section engineering-section">
	<div class="container">
		<div class="engineering-heading">
			<h2>Designed beyond the happy path</h2>
			<p>The application models the operational problems that make equipment hire interesting.</p>
		</div>

		<div class="decision-list">
			<article>
				<h3>Products and physical units</h3>
				<p>
					Customers reserve a product and quantity. Staff can allocate or replace the actual tracked
					units without rewriting the customer's booking.
				</p>
			</article>
			<article>
				<h3>Period-aware availability</h3>
				<p>
					Hire periods use half-open intervals and account for bookings, unit condition and
					scheduled maintenance.
				</p>
			</article>
			<article>
				<h3>Guest and authenticated baskets</h3>
				<p>
					The data model supports server-backed guest baskets that can be retained through the
					authentication flow.
				</p>
			</article>
			<article>
				<h3>Repeatable database changes</h3>
				<p>
					The PostgreSQL model is maintained with reviewed, versioned Atlas migrations and explicit
					integrity constraints.
				</p>
			</article>
		</div>
	</div>
</section>

<section class="project-note">
	<div class="container note-layout">
		<div>
			<h2>Built as a working system</h2>
			<p>
				This is an actively developed portfolio application. The catalogue and database foundation
				are available now; booking, fulfilment and administration workflows are being developed in
				stages.
			</p>
		</div>
		<a class="primary-action" href="/home">Enter the demo</a>
	</div>
</section>

<style>
	.portfolio-hero {
		padding: clamp(3rem, 6vw, 5rem) 0;
		background: var(--ink);
		color: #fff;
	}

	.hero-layout {
		display: grid;
		grid-template-columns: minmax(0, 1.3fr) minmax(18rem, 0.7fr);
		align-items: center;
		gap: clamp(3rem, 7vw, 7rem);
	}

	.project-byline {
		margin: 0 0 1.25rem;
		color: #d6d3ca;
		font-size: 0.9rem;
	}

	h1 {
		max-width: 18ch;
		margin: 0;
		font-size: clamp(2.4rem, 5vw, 3.5rem);
		font-weight: 720;
		letter-spacing: -0.045em;
		line-height: 1.04;
	}

	.hero-summary {
		max-width: 46rem;
		margin: 1.5rem 0 0;
		color: #d6d3ca;
		font-size: 1rem;
		line-height: 1.65;
	}

	.hero-actions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.75rem;
		margin-top: 2rem;
	}

	.primary-action,
	.secondary-action {
		display: inline-flex;
		min-height: 2.9rem;
		align-items: center;
		justify-content: center;
		padding: 0.65rem 1rem;
		font-weight: 700;
		text-decoration: none;
	}

	.primary-action {
		border: 1px solid var(--brand);
		background: var(--brand);
		color: #fff;
	}

	.primary-action:hover {
		border-color: var(--brand-dark);
		background: var(--brand-dark);
	}

	.secondary-action {
		border: 1px solid #777970;
		color: #fff;
	}

	.secondary-action:hover {
		border-color: #fff;
	}

	.project-facts {
		border-top: 1px solid #777970;
	}

	.project-facts div {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		padding: 0.9rem 0;
		border-bottom: 1px solid #4b4d47;
	}

	.project-facts span {
		color: #aaa9a2;
		font-size: 0.76rem;
	}

	.project-facts strong {
		font-size: 0.88rem;
		text-align: right;
	}

	.split-layout {
		display: grid;
		grid-template-columns: minmax(16rem, 0.72fr) minmax(0, 1.28fr);
		gap: clamp(3rem, 8vw, 7rem);
	}

	.section-heading h2,
	.engineering-heading h2,
	.note-layout h2 {
		margin: 0;
		font-size: clamp(1.7rem, 3vw, 2.2rem);
		letter-spacing: -0.035em;
	}

	.section-heading p,
	.engineering-heading p,
	.note-layout p {
		margin: 0.8rem 0 0;
		color: var(--muted);
		line-height: 1.65;
	}

	.demo-routes {
		margin: 0;
		padding: 0;
		border-top: 1px solid var(--ink);
		list-style: none;
	}

	.demo-routes li {
		display: grid;
		grid-template-columns: 2.5rem 1fr;
		gap: 1rem;
		padding: 1.35rem 0;
		border-bottom: 1px solid var(--line);
	}

	.demo-routes li > span {
		color: var(--brand-dark);
		font-family: ui-monospace, monospace;
		font-size: 0.8rem;
		font-weight: 750;
	}

	.demo-routes h3,
	.decision-list h3 {
		margin: 0;
		font-size: 1rem;
	}

	.demo-routes p,
	.decision-list p {
		margin: 0.4rem 0 0;
		color: var(--muted);
		font-size: 0.9rem;
		line-height: 1.55;
	}

	.demo-routes a {
		display: inline-block;
		margin-top: 0.65rem;
		color: var(--brand-dark);
		font-size: 0.86rem;
		font-weight: 700;
		text-underline-offset: 0.2rem;
	}

	.engineering-section {
		border-top: 1px solid var(--line);
		background: var(--surface-alt);
	}

	.engineering-heading {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 2rem;
		margin-bottom: 2rem;
	}

	.engineering-heading p {
		max-width: 31rem;
	}

	.decision-list {
		display: grid;
		grid-template-columns: 1fr 1fr;
		border-top: 1px solid var(--ink);
	}

	.decision-list article {
		padding: 1.4rem 2rem 1.4rem 0;
		border-bottom: 1px solid var(--line);
	}

	.decision-list article:nth-child(even) {
		padding-right: 0;
		padding-left: 2rem;
		border-left: 1px solid var(--line);
	}

	.project-note {
		padding: 2.5rem 0;
		border-top: 1px solid var(--line);
		background: var(--surface);
	}

	.note-layout {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 3rem;
	}

	.note-layout > div {
		max-width: 46rem;
	}

	.note-layout h2 {
		font-size: 1.5rem;
	}

	.note-layout .primary-action {
		flex: 0 0 auto;
	}

	@media (max-width: 820px) {
		.hero-layout,
		.split-layout {
			grid-template-columns: 1fr;
		}

		.project-facts {
			max-width: 35rem;
		}

		.engineering-heading,
		.note-layout {
			align-items: flex-start;
			flex-direction: column;
		}
	}

	@media (max-width: 560px) {
		.portfolio-hero {
			padding: 2.75rem 0;
		}

		h1 {
			font-size: clamp(2.25rem, 11vw, 3rem);
		}

		.hero-actions,
		.hero-actions a {
			width: 100%;
		}

		.decision-list {
			grid-template-columns: 1fr;
		}

		.decision-list article,
		.decision-list article:nth-child(even) {
			padding: 1.2rem 0;
			border-left: 0;
		}
	}
</style>
