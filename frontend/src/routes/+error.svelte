<script lang="ts">
	import { page } from '$app/state';

	const isNotFound = $derived(page.status === 404);
	const title = $derived(isNotFound ? 'Page not found' : 'Something went wrong');
	const message = $derived(
		isNotFound
			? 'The requested page does not exist or may have moved.'
			: 'The application could not complete this request. Try returning to the store.'
	);
</script>

<svelte:head>
	<title>{page.status} {title} · Equipment Hire</title>
</svelte:head>

<section class="error-page">
	<div class="container error-layout">
		<p class="status-code">{page.status}</p>
		<div>
			<h1>{title}</h1>
			<p>{message}</p>
			<div class="error-actions">
				<a class="primary" href="/home">Customer home</a>
				<a href="/equipment">Browse equipment</a>
			</div>
		</div>
	</div>
</section>

<style>
	.error-page {
		padding: clamp(3rem, 8vw, 7rem) 0;
	}

	.error-layout {
		display: grid;
		grid-template-columns: minmax(7rem, 0.3fr) minmax(0, 1fr);
		gap: clamp(2rem, 7vw, 6rem);
		max-width: 55rem;
	}

	.status-code {
		margin: 0;
		padding-top: 0.35rem;
		border-top: 3px solid var(--brand);
		color: var(--muted);
		font-family: ui-monospace, monospace;
		font-size: 1.15rem;
		font-variant-numeric: tabular-nums;
	}

	h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(2rem, 4vw, 2.35rem);
		letter-spacing: -0.035em;
	}

	h1 + p {
		max-width: 36rem;
		margin: 0.75rem 0 0;
		color: var(--muted);
	}

	.error-actions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.75rem;
		margin-top: 1.75rem;
	}

	.error-actions a {
		display: inline-flex;
		min-height: 2.8rem;
		align-items: center;
		padding: 0.6rem 0.9rem;
		border: 1px solid var(--line-dark);
		background: var(--surface);
		font-weight: 650;
		text-decoration: none;
	}

	.error-actions a.primary {
		border-color: var(--brand-dark);
		background: var(--brand);
		color: #fff;
	}

	@media (max-width: 540px) {
		.error-layout {
			grid-template-columns: 1fr;
			gap: 1.25rem;
		}
	}
</style>
