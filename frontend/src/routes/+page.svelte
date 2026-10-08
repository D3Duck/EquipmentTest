<svelte:head>
	<title>Equipment Hire · Portfolio Project</title>
	<meta
		name="description"
		content="A portfolio equipment-hire application with live availability, quantity-aware booking and managed physical inventory."
	/>
</svelte:head>

<section class="hero">
	<div class="container hero-grid">
		<div>
			<p class="eyebrow">Equipment hire, without the guesswork</p>
			<h1>Borrow the gear. Keep the momentum.</h1>
			<p class="hero-copy">
				Browse real inventory, choose exactly when you need it, and reserve with confidence. This
				demo brings customer booking and store operations into one focused workflow.
			</p>
			<div class="hero-actions">
				<a class="button button-primary" href="/equipment">
					Browse equipment
					<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
						<path
							d="M5 12h14m-5-5 5 5-5 5"
							stroke="currentColor"
							stroke-width="2"
							stroke-linecap="round"
							stroke-linejoin="round"
						/>
					</svg>
				</a>
				<a class="button button-secondary" href="#how-it-works">See how it works</a>
			</div>
			<p class="hero-note">
				<span class="status-dot" aria-hidden="true"></span> Demo environment with sample equipment and
				bookings
			</p>
		</div>

		<div class="availability-card" aria-label="Example equipment availability">
			<div class="card-topline">
				<strong>Quick availability</strong>
				<span class="demo-pill">Live demo</span>
			</div>
			<div class="date-grid">
				<div class="date-field"><span>Start date</span><strong>12 Oct 2026</strong></div>
				<div class="date-field"><span>End date</span><strong>14 Oct 2026</strong></div>
			</div>
			<div class="availability-list">
				<div class="availability-row">
					<span class="item-icon" aria-hidden="true">◈</span>
					<span class="item-name">Cordless drill <small>Tools</small></span>
					<span class="quantity">3 available</span>
				</div>
				<div class="availability-row">
					<span class="item-icon" aria-hidden="true">◎</span>
					<span class="item-name">Camera kit <small>Photography</small></span>
					<span class="quantity">2 available</span>
				</div>
				<div class="availability-row">
					<span class="item-icon" aria-hidden="true">△</span>
					<span class="item-name">Camping tent <small>Outdoor</small></span>
					<span class="quantity">4 available</span>
				</div>
			</div>
			<a class="button button-primary" href="/equipment">Check availability</a>
		</div>
	</div>
</section>

<section class="section section-tinted" id="how-it-works">
	<div class="container">
		<div class="section-heading">
			<div>
				<p class="section-kicker">Simple by design</p>
				<h2>From search to reservation in three steps.</h2>
			</div>
			<p>
				Pick a period once, compare what is genuinely available, and keep every booking in one
				place.
			</p>
		</div>
		<div class="step-grid">
			<article class="step-card">
				<span class="step-number">01</span>
				<h3>Choose your dates</h3>
				<p>Set the full hire period to see accurate quantities across the catalogue.</p>
			</article>
			<article class="step-card">
				<span class="step-number">02</span>
				<h3>Build your booking</h3>
				<p>
					Add equipment and quantities to a basket, then review the complete hire before checkout.
				</p>
			</article>
			<article class="step-card">
				<span class="step-number">03</span>
				<h3>Reserve confidently</h3>
				<p>Availability is checked again at checkout so inventory cannot be overbooked.</p>
			</article>
		</div>
	</div>
</section>

<section class="section">
	<div class="container">
		<div class="section-heading">
			<div>
				<p class="section-kicker">Built for both sides of the counter</p>
				<h2>A realistic workflow, not just a catalogue.</h2>
			</div>
			<p>
				The project connects a clear customer journey with the inventory controls a hire store
				actually needs.
			</p>
		</div>
		<div class="feature-grid">
			<article class="feature-card">
				<span class="feature-icon" aria-hidden="true">
					<svg width="21" height="21" viewBox="0 0 24 24" fill="none"
						><path
							d="M5 3v3M19 3v3M4 9h16M5 5h14a1 1 0 0 1 1 1v14H4V6a1 1 0 0 1 1-1Z"
							stroke="currentColor"
							stroke-width="1.8"
							stroke-linecap="round"
							stroke-linejoin="round"
						/></svg
					>
				</span>
				<h3>Period-aware availability</h3>
				<p>
					Customers see the quantity available for their full hire period, including maintenance
					exclusions.
				</p>
			</article>
			<article class="feature-card">
				<span class="feature-icon" aria-hidden="true">
					<svg width="21" height="21" viewBox="0 0 24 24" fill="none"
						><path
							d="M12 3 5 6v5c0 4.6 2.9 8.1 7 10 4.1-1.9 7-5.4 7-10V6l-7-3Z"
							stroke="currentColor"
							stroke-width="1.8"
							stroke-linejoin="round"
						/><path
							d="m9 12 2 2 4-4"
							stroke="currentColor"
							stroke-width="1.8"
							stroke-linecap="round"
							stroke-linejoin="round"
						/></svg
					>
				</span>
				<h3>Protected reservations</h3>
				<p>
					Transactional checkout and database safeguards are designed to prevent competing
					overbookings.
				</p>
			</article>
			<article class="feature-card">
				<span class="feature-icon" aria-hidden="true">
					<svg width="21" height="21" viewBox="0 0 24 24" fill="none"
						><path
							d="M4 7h16v13H4zM8 7V4h8v3M8 12h8M8 16h5"
							stroke="currentColor"
							stroke-width="1.8"
							stroke-linecap="round"
							stroke-linejoin="round"
						/></svg
					>
				</span>
				<h3>Physical inventory control</h3>
				<p>
					Store staff can track individual units, maintenance, collection, return, and overdue
					equipment.
				</p>
			</article>
		</div>
	</div>
</section>

<section class="section">
	<div class="container">
		<div class="tech-strip">
			<div>
				<h2>One focused, full-stack build.</h2>
				<p>
					Designed to demonstrate thoughtful domain modelling, real-time updates, database
					concurrency and repeatable deployment.
				</p>
			</div>
			<div class="tech-list" aria-label="Technology stack">
				<span>Svelte 5</span>
				<span>Go</span>
				<span>PostgreSQL</span>
				<span>Atlas</span>
				<span>Docker</span>
			</div>
		</div>
	</div>
</section>

<style>
	.hero {
		padding: clamp(3rem, 6vw, 5rem) 0 4rem;
	}

	.hero-grid {
		display: grid;
		grid-template-columns: minmax(0, 1.08fr) minmax(21rem, 0.82fr);
		align-items: center;
		gap: clamp(3rem, 7vw, 6.5rem);
	}

	.eyebrow {
		margin: 0 0 1rem;
		color: var(--brand-dark);
		font-size: 0.78rem;
		font-weight: 780;
		letter-spacing: 0.13em;
		text-transform: uppercase;
	}

	.hero h1 {
		max-width: 12ch;
		margin: 0;
		color: var(--navy);
		font-size: clamp(3rem, 7vw, 5.7rem);
		font-weight: 790;
		letter-spacing: -0.065em;
		line-height: 0.98;
	}

	.hero-copy {
		max-width: 38rem;
		margin: 1.6rem 0 0;
		color: var(--muted);
		font-size: clamp(1.05rem, 2vw, 1.23rem);
		line-height: 1.7;
	}

	.hero-actions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.8rem;
		margin-top: 2rem;
	}

	.button {
		display: inline-flex;
		min-height: 3.1rem;
		align-items: center;
		justify-content: center;
		gap: 0.6rem;
		padding: 0.75rem 1.15rem;
		border: 1px solid transparent;
		border-radius: 0.78rem;
		font-weight: 720;
		text-decoration: none;
		transition:
			transform 150ms ease,
			box-shadow 150ms ease,
			background 150ms ease;
	}

	.button:hover {
		transform: translateY(-1px);
	}

	.button-primary {
		background: var(--brand);
		color: #fff;
		box-shadow: 0 12px 28px rgba(8, 127, 121, 0.22);
	}

	.button-primary:hover {
		background: var(--brand-dark);
	}

	.button-secondary {
		border-color: var(--line);
		background: rgba(255, 255, 255, 0.74);
		color: var(--navy);
	}

	.button-secondary:hover {
		background: #fff;
		box-shadow: 0 10px 25px rgba(16, 38, 76, 0.08);
	}

	.hero-note {
		display: flex;
		align-items: center;
		gap: 0.55rem;
		margin: 1.35rem 0 0;
		color: #66758c;
		font-size: 0.88rem;
	}

	.status-dot {
		width: 0.55rem;
		height: 0.55rem;
		border-radius: 50%;
		background: #17a673;
		box-shadow: 0 0 0 5px rgba(23, 166, 115, 0.12);
	}

	.availability-card {
		position: relative;
		padding: 1.5rem;
		border: 1px solid rgba(216, 224, 234, 0.9);
		border-radius: var(--radius-lg);
		background: rgba(255, 255, 255, 0.92);
		box-shadow: var(--shadow);
	}

	.availability-card::before {
		position: absolute;
		top: -1.1rem;
		right: 2.4rem;
		width: 5rem;
		height: 0.3rem;
		border-radius: 999px;
		background: #f0b24b;
		content: '';
	}

	.card-topline {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 1rem;
		margin-bottom: 1.4rem;
	}

	.card-topline strong {
		color: var(--navy);
		font-size: 1.03rem;
	}

	.demo-pill {
		padding: 0.35rem 0.6rem;
		border-radius: 999px;
		background: var(--brand-soft);
		color: var(--brand-dark);
		font-size: 0.72rem;
		font-weight: 760;
		letter-spacing: 0.04em;
		text-transform: uppercase;
	}

	.date-grid {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.75rem;
	}

	.date-field {
		padding: 0.8rem 0.9rem;
		border: 1px solid var(--line);
		border-radius: var(--radius-sm);
		background: #fbfcfd;
	}

	.date-field span {
		display: block;
		margin-bottom: 0.3rem;
		color: var(--muted);
		font-size: 0.72rem;
	}

	.date-field strong {
		color: var(--navy);
		font-size: 0.93rem;
	}

	.availability-list {
		display: grid;
		gap: 0.7rem;
		margin: 1.25rem 0;
	}

	.availability-row {
		display: grid;
		grid-template-columns: auto 1fr auto;
		align-items: center;
		gap: 0.75rem;
		padding: 0.8rem;
		border-radius: var(--radius-sm);
		background: var(--surface-alt);
	}

	.item-icon {
		display: grid;
		width: 2.3rem;
		height: 2.3rem;
		place-items: center;
		border-radius: 0.6rem;
		background: #fff;
		font-size: 1.1rem;
	}

	.item-name {
		display: grid;
		gap: 0.15rem;
		color: var(--navy);
		font-size: 0.88rem;
		font-weight: 700;
	}

	.item-name small {
		color: var(--muted);
		font-size: 0.7rem;
		font-weight: 520;
	}

	.quantity {
		color: var(--brand-dark);
		font-size: 0.75rem;
		font-weight: 740;
	}

	.availability-card .button {
		width: 100%;
	}

	.section-tinted {
		border-block: 1px solid var(--line);
		background: rgba(255, 255, 255, 0.68);
	}

	.section-heading {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 2rem;
		margin-bottom: 2rem;
	}

	.section-heading h2 {
		max-width: 17ch;
		margin: 0;
		color: var(--navy);
		font-size: clamp(2rem, 4vw, 3rem);
		letter-spacing: -0.045em;
		line-height: 1.1;
	}

	.section-heading p:last-child {
		max-width: 30rem;
		margin: 0;
		color: var(--muted);
		line-height: 1.7;
	}

	.step-grid,
	.feature-grid {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 1rem;
	}

	.step-card,
	.feature-card {
		border: 1px solid var(--line);
		border-radius: var(--radius-md);
		background: var(--surface);
	}

	.step-card {
		padding: 1.5rem;
	}

	.step-number {
		display: grid;
		width: 2.4rem;
		height: 2.4rem;
		place-items: center;
		margin-bottom: 1.6rem;
		border-radius: 50%;
		background: var(--brand-soft);
		color: var(--brand-dark);
		font-size: 0.82rem;
		font-weight: 800;
	}

	.step-card h3,
	.feature-card h3 {
		margin: 0 0 0.55rem;
		color: var(--navy);
		font-size: 1.05rem;
	}

	.step-card p,
	.feature-card p {
		margin: 0;
		color: var(--muted);
		font-size: 0.92rem;
		line-height: 1.65;
	}

	.feature-card {
		padding: 1.6rem;
		background: linear-gradient(155deg, #fff, #f8fafc);
	}

	.feature-icon {
		display: grid;
		width: 2.8rem;
		height: 2.8rem;
		place-items: center;
		margin-bottom: 1.4rem;
		border-radius: 0.78rem;
		background: var(--navy);
		color: #fff;
	}

	.tech-strip {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 2rem;
		padding: 2rem;
		border-radius: var(--radius-lg);
		background: var(--navy);
		color: #fff;
	}

	.tech-strip h2 {
		margin: 0 0 0.45rem;
		font-size: clamp(1.5rem, 3vw, 2.1rem);
		letter-spacing: -0.035em;
	}

	.tech-strip p {
		max-width: 42rem;
		margin: 0;
		color: #bdc9dc;
		line-height: 1.6;
	}

	.tech-list {
		display: flex;
		flex-wrap: wrap;
		justify-content: flex-end;
		gap: 0.5rem;
	}

	.tech-list span {
		padding: 0.5rem 0.75rem;
		border: 1px solid rgba(255, 255, 255, 0.18);
		border-radius: 999px;
		background: rgba(255, 255, 255, 0.08);
		font-size: 0.8rem;
		font-weight: 680;
	}

	@media (max-width: 860px) {
		.hero-grid {
			grid-template-columns: 1fr;
		}

		.hero-copy {
			max-width: 45rem;
		}

		.availability-card {
			max-width: 38rem;
		}

		.section-heading,
		.tech-strip {
			align-items: flex-start;
			flex-direction: column;
		}

		.section-heading {
			display: grid;
		}

		.step-grid,
		.feature-grid {
			grid-template-columns: 1fr;
		}

		.tech-list {
			justify-content: flex-start;
		}
	}

	@media (max-width: 560px) {
		.hero {
			padding-top: 2.75rem;
		}

		.hero h1 {
			font-size: clamp(2.65rem, 15vw, 4rem);
		}

		.hero-actions,
		.hero-actions .button {
			width: 100%;
		}

		.date-grid {
			grid-template-columns: 1fr;
		}

		.tech-strip {
			padding: 1.5rem;
		}
	}

	@media (prefers-reduced-motion: reduce) {
		.button {
			transition: none;
		}
	}
</style>
