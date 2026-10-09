<script lang="ts">
	let startDate = $state('');
	let endDate = $state('');
	const minimumEndDate = $derived(startDate ? nextDate(startDate) : undefined);

	function nextDate(value: string) {
		const [year, month, day] = value.split('-').map(Number);
		return new Date(Date.UTC(year, month - 1, day + 1)).toISOString().slice(0, 10);
	}
</script>

<svelte:head>
	<title>Home · Equipment Hire</title>
	<meta
		name="description"
		content="Reserve tools, cleaning equipment, site gear and AV equipment for collection from our Sydney depot."
	/>
</svelte:head>

<section class="hero">
	<div class="container hero-layout">
		<div class="hero-copy">
			<h1>Equipment ready for collection.</h1>
			<p>
				Browse practical equipment for trade, site, cleaning, outdoor, and event work. Set your hire
				window, compare current stock, and collect from our Sydney depot.
			</p>
			<div class="hero-actions">
				<a class="primary-action" href="/equipment">Browse equipment</a>
				<a class="text-link" href="#hire-process">How collection works</a>
			</div>

			<dl class="depot-summary">
				<div>
					<dt>Collection</dt>
					<dd>From 7:00 am</dd>
				</div>
				<div>
					<dt>Location</dt>
					<dd>Sydney depot</dd>
				</div>
				<div>
					<dt>Stock</dt>
					<dd>75 tracked units</dd>
				</div>
			</dl>
		</div>

		<figure class="hero-product">
			<img
				src="/images/products/Floor_sander_on_grey_background_20261007221651.jpg"
				alt="Orbital floor sander available for hire"
				width="1200"
				height="896"
			/>
			<figcaption>
				<span><strong>Orbital floor sander</strong> FL-004 · current demo stock: 1 of 2</span>
				<strong>$86/day</strong>
			</figcaption>
		</figure>
	</div>

	<div class="container">
		<form class="availability-search" action="/equipment" method="get">
			<div class="search-heading">
				<span aria-hidden="true">01</span>
				<div>
					<h2>Set a hire window</h2>
					<p>Carry dates into the catalogue.</p>
				</div>
			</div>
			<label>
				<span>Start date</span>
				<input name="start" type="date" bind:value={startDate} required />
			</label>
			<label>
				<span>End date</span>
				<input name="end" type="date" min={minimumEndDate} bind:value={endDate} required />
			</label>
			<button type="submit">Browse these dates</button>
		</form>
	</div>
</section>

<section class="section" id="hire-process">
	<div class="container process-layout">
		<div class="section-intro">
			<h2>Hiring equipment</h2>
			<p>A straightforward reservation and depot collection process.</p>
		</div>
		<ol class="process-list">
			<li>
				<span>1</span>
				<div>
					<h3>Choose each item and its dates</h3>
					<p>Availability includes existing bookings, maintenance and retired equipment.</p>
				</div>
			</li>
			<li>
				<span>2</span>
				<div>
					<h3>Review and reserve</h3>
					<p>Prices and stock are checked once more before the booking is confirmed.</p>
				</div>
			</li>
			<li>
				<span>3</span>
				<div>
					<h3>Collect from the depot</h3>
					<p>Staff allocate the physical units and record collection and return.</p>
				</div>
			</li>
		</ol>
	</div>
</section>

<section class="section depot-section">
	<div class="container depot-layout">
		<div>
			<h2>Sydney hire desk</h2>
			<p>
				Bring photo identification when collecting equipment. Specific physical units are assigned
				by depot staff before collection.
			</p>
			<a class="text-link" href="/equipment">See all equipment</a>
		</div>
		<dl class="depot-details">
			<div>
				<dt>Monday–Friday</dt>
				<dd>7:00 am–5:30 pm</dd>
			</div>
			<div>
				<dt>Saturday</dt>
				<dd>8:00 am–2:00 pm</dd>
			</div>
			<div>
				<dt>Sunday</dt>
				<dd>Closed</dd>
			</div>
			<div>
				<dt>Returns</dt>
				<dd>Due before closing</dd>
			</div>
		</dl>
	</div>
</section>

<style>
	.hero {
		padding: clamp(2rem, 4vw, 3.5rem) 0 0;
		border-bottom: 1px solid var(--line);
		background: var(--surface);
	}

	.hero-layout {
		display: grid;
		grid-template-columns: minmax(0, 1.05fr) minmax(20rem, 0.72fr);
		align-items: end;
		gap: clamp(2.5rem, 6vw, 5.5rem);
	}

	.hero-copy h1 {
		max-width: 15ch;
		margin: 0;
		color: var(--ink);
		font-size: clamp(2.35rem, 4.5vw, 3.35rem);
		font-weight: 720;
		letter-spacing: -0.04em;
		line-height: 1.05;
	}

	.hero-copy > p {
		max-width: 37rem;
		margin: 1.35rem 0 0;
		color: var(--muted);
		font-size: 1rem;
		line-height: 1.6;
	}

	.hero-actions {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: 1.25rem;
		margin-top: 1.75rem;
	}

	.primary-action,
	.availability-search button {
		display: inline-flex;
		min-height: 2.85rem;
		align-items: center;
		justify-content: center;
		padding: 0.65rem 1rem;
		border: 1px solid var(--brand-dark);
		background: var(--brand);
		color: #fff;
		font-weight: 700;
		text-decoration: none;
		cursor: pointer;
	}

	.primary-action:hover,
	.availability-search button:hover {
		background: var(--brand-dark);
	}

	.text-link {
		color: var(--ink);
		font-weight: 680;
		text-decoration-color: var(--brand);
		text-decoration-thickness: 2px;
		text-underline-offset: 0.25rem;
	}

	.depot-summary {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		margin: 2rem 0 0;
		border-top: 1px solid var(--line);
	}

	.depot-summary div {
		padding: 0.85rem 1rem 0 0;
	}

	.depot-summary dt,
	.depot-details dt {
		color: var(--muted);
		font-size: 0.75rem;
	}

	.depot-summary dd,
	.depot-details dd {
		margin: 0.25rem 0 0;
		color: var(--ink);
		font-size: 0.9rem;
		font-weight: 680;
	}

	.hero-product {
		margin: 0;
		border: 1px solid var(--line-dark);
		background: #eef0ef;
	}

	.hero-product img {
		display: block;
		width: 100%;
		height: auto;
		aspect-ratio: 4 / 3;
		object-fit: contain;
	}

	.hero-product figcaption {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 1rem;
		padding: 0.85rem 1rem;
		border-top: 1px solid var(--line);
		font-size: 0.82rem;
	}

	.hero-product figcaption span {
		display: grid;
		gap: 0.15rem;
		color: var(--muted);
	}

	.hero-product figcaption span strong {
		color: var(--ink);
	}

	.hero-product figcaption > strong {
		white-space: nowrap;
		font-size: 1rem;
	}

	.availability-search {
		display: grid;
		grid-template-columns: minmax(14rem, 1fr) minmax(10rem, 0.55fr) minmax(10rem, 0.55fr) auto;
		align-items: end;
		gap: 1rem;
		margin-top: clamp(2rem, 4vw, 3.25rem);
		padding: 1rem 1.2rem;
		border: 1px solid var(--line-dark);
		border-bottom: 0;
		background: var(--ink);
		color: #fff;
	}

	.search-heading {
		display: flex;
		align-items: center;
		gap: 0.8rem;
	}

	.search-heading > span {
		color: #d47c66;
		font-family: ui-monospace, monospace;
		font-size: 0.75rem;
	}

	.search-heading h2 {
		margin: 0;
		font-size: 1.05rem;
	}

	.search-heading p {
		margin: 0.3rem 0 0;
		color: #adb5b0;
		font-size: 0.8rem;
	}

	.availability-search label {
		display: grid;
		gap: 0.4rem;
		color: #f4f3ef;
		font-size: 0.76rem;
		font-weight: 650;
	}

	.availability-search input {
		width: 100%;
		height: 2.85rem;
		padding: 0 0.75rem;
		border: 1px solid var(--line-dark);
		border-radius: var(--radius-sm);
		background: #fff;
		color: var(--ink);
	}

	.section-intro h2,
	.depot-layout h2 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(1.55rem, 3vw, 2rem);
		letter-spacing: -0.03em;
	}

	.section-intro p,
	.depot-layout > div > p {
		max-width: 30rem;
		margin: 0.65rem 0 0;
		color: var(--muted);
		line-height: 1.65;
	}

	.process-layout {
		display: grid;
		grid-template-columns: minmax(14rem, 0.65fr) minmax(0, 1.35fr);
		gap: clamp(2rem, 7vw, 6rem);
	}

	.process-list {
		margin: 0;
		padding: 0;
		border-top: 1px solid var(--ink);
		list-style: none;
	}

	.process-list li {
		display: grid;
		grid-template-columns: 2rem 1fr;
		gap: 1rem;
		padding: 1.25rem 0;
		border-bottom: 1px solid var(--line);
	}

	.process-list li > span {
		color: var(--brand-dark);
		font-family: ui-monospace, monospace;
		font-weight: 750;
	}

	.process-list h3 {
		margin: 0;
		font-size: 1rem;
	}

	.process-list p {
		margin: 0.35rem 0 0;
		color: var(--muted);
		font-size: 0.9rem;
		line-height: 1.55;
	}

	.depot-section {
		border-top: 1px solid var(--line);
		background: var(--surface-alt);
	}

	.depot-layout {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: clamp(2rem, 7vw, 6rem);
	}

	.depot-layout .text-link {
		display: inline-block;
		margin-top: 1.25rem;
	}

	.depot-details {
		margin: 0;
		border-top: 1px solid var(--ink);
	}

	.depot-details div {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		padding: 0.8rem 0;
		border-bottom: 1px solid var(--line);
	}

	.depot-details dd {
		text-align: right;
	}

	@media (max-width: 820px) {
		.hero-layout,
		.process-layout,
		.depot-layout {
			grid-template-columns: 1fr;
		}

		.hero-product {
			max-width: 38rem;
		}

		.availability-search {
			grid-template-columns: 1fr 1fr;
		}

		.search-heading {
			grid-column: 1 / -1;
		}
	}

	@media (max-width: 540px) {
		.hero-copy h1 {
			font-size: clamp(2.1rem, 10vw, 2.75rem);
		}

		.depot-summary {
			grid-template-columns: 1fr;
		}

		.depot-summary div {
			display: flex;
			justify-content: space-between;
			padding: 0.7rem 0;
			border-bottom: 1px solid var(--line);
		}

		.depot-summary dd {
			margin: 0;
		}

		.availability-search {
			grid-template-columns: 1fr;
			margin-inline: -0.625rem;
		}

		.search-heading {
			grid-column: auto;
		}

		.availability-search button {
			width: 100%;
		}
	}
</style>
