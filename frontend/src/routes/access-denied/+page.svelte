<script lang="ts">
	import { authState, defaultPathForRole } from '#lib/auth.ts';

	const returnPath = $derived(
		$authState.user ? defaultPathForRole($authState.user.role) : '/equipment'
	);
</script>

<svelte:head>
	<title>Access denied · Equipment Hire</title>
	<meta name="description" content="This account cannot access the requested workspace." />
</svelte:head>

<section class="access-page">
	<div class="access-card">
		<p class="eyebrow">403 · Role boundary</p>
		<h1>Access denied</h1>
		<p>
			{#if $authState.user}
				<strong>{$authState.user.display_name}</strong> is signed in as
				<code>{$authState.user.role}</code>, which cannot access that workspace.
			{:else}
				This account cannot access the requested workspace.
			{/if}
		</p>
		<div class="actions">
			<a class="primary" href={returnPath}>Return to your workspace</a>
			<a href="/login">Use another account</a>
		</div>
	</div>
</section>

<style>
	.access-page {
		display: grid;
		min-height: calc(100vh - 17rem);
		place-items: center;
		padding: 3rem var(--page-gutter);
	}

	.access-card {
		width: min(100%, 38rem);
		padding: clamp(1.5rem, 5vw, 2.5rem);
		border: 1px solid var(--line-dark);
		border-left: 5px solid var(--danger);
		background: var(--surface);
	}

	.eyebrow {
		margin: 0;
		color: var(--danger);
		font:
			0.76rem ui-monospace,
			monospace;
		text-transform: uppercase;
	}

	h1 {
		margin: 0.65rem 0 0;
		color: var(--ink);
		font-size: clamp(2rem, 6vw, 3rem);
		letter-spacing: -0.04em;
	}

	.access-card > p:not(.eyebrow) {
		margin: 1rem 0 0;
		color: var(--muted);
		line-height: 1.65;
	}

	code {
		color: var(--ink);
	}

	.actions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.75rem;
		margin-top: 1.75rem;
	}

	.actions a {
		display: inline-flex;
		min-height: 2.8rem;
		align-items: center;
		padding: 0 1rem;
		border: 1px solid var(--line-dark);
		background: var(--surface-alt);
		color: var(--ink);
		font-weight: 700;
		text-decoration: none;
	}

	.actions .primary {
		border-color: var(--ink);
		background: var(--ink);
		color: #fff;
	}
</style>
