<svelte:head>
	<title>Equipment Catalogue · Equipment Hire</title>
</svelte:head>

<section class="section">
	<div class="container page-intro">
		<p class="section-kicker">Catalogue / Sydney depot</p>
		<h1>Equipment for the job ahead.</h1>
		<p class="intro-copy">
			Set your hire period to check live quantities across tools, cleaning, access, outdoor, and AV
			equipment.
		</p>

		<div class="depot-strip" aria-label="Depot summary">
			<span><strong>42</strong> products</span>
			<span><strong>68</strong> tracked units</span>
			<span><strong>07:00</strong> first collection</span>
		</div>
	</div>
</section>

<style>
	.page-intro h1 {
		max-width: 12ch;
		margin: 0;
		color: var(--navy);
		font-size: clamp(2.75rem, 6vw, 4.75rem);
		font-weight: 850;
		letter-spacing: -0.05em;
		line-height: 0.98;
	}

	.intro-copy {
		max-width: 38rem;
		margin: 1rem 0 0;
		color: var(--muted);
		font-size: 1.05rem;
		line-height: 1.7;
	}

	.depot-strip {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		max-width: 48rem;
		margin-top: 2.5rem;
		border: 2px solid var(--ink);
		border-left: 8px solid var(--brand);
		background: var(--surface);
		box-shadow: var(--shadow);
	}

	.depot-strip span {
		display: grid;
		gap: 0.25rem;
		padding: 1rem 1.2rem;
		border-right: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.78rem;
		font-weight: 700;
		letter-spacing: 0.05em;
		text-transform: uppercase;
	}

	.depot-strip span:last-child {
		border-right: 0;
	}

	.depot-strip strong {
		color: var(--ink);
		font-family: ui-monospace, monospace;
		font-size: 1.15rem;
	}

	@media (max-width: 600px) {
		.depot-strip {
			grid-template-columns: 1fr;
		}

		.depot-strip span {
			border-right: 0;
			border-bottom: 1px solid var(--line);
		}

		.depot-strip span:last-child {
			border-bottom: 0;
		}
	}
</style>
