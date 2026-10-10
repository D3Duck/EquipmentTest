<script lang="ts">
	import { page } from '$app/state';
	import { onMount } from 'svelte';
	import ToolCard from '#lib/components/ToolCard.svelte';
	import type { EquipmentProduct } from '#lib/types.ts';

	type SortOption = 'name-asc' | 'rate-asc' | 'rate-desc' | 'stock-desc';
	let products = $state<EquipmentProduct[]>([]);
	let isLoading = $state(true);
	let loadError = $state('');
	let searchQuery = $state(page.url.searchParams.get('q') ?? '');
	let selectedCategory = $state('All equipment');
	let sortOption = $state<SortOption>('name-asc');
	const requestedStart = page.url.searchParams.get('start') ?? '';
	const requestedEnd = page.url.searchParams.get('end') ?? '';
	const hasRequestedWindow =
		isValidDate(requestedStart) && isValidDate(requestedEnd) && requestedEnd > requestedStart;

	onMount(loadProducts);

	const categoryCounts = $derived.by(() => {
		const counts: Record<string, number> = {};
		for (const product of products) {
			counts[product.category.name] = (counts[product.category.name] ?? 0) + 1;
		}
		return Object.entries(counts).map(([name, count]) => ({ name, count }));
	});

	const filteredProducts = $derived.by(() => {
		const query = searchQuery.trim().toLowerCase();
		const matches = products.filter(
			(product) =>
				(selectedCategory === 'All equipment' || product.category.name === selectedCategory) &&
				(!query ||
					[product.name, product.description, product.category.name, product.catalogue_code].some(
						(value) => value.toLowerCase().includes(query)
					))
		);
		return [...matches].sort((a, b) => {
			switch (sortOption) {
				case 'rate-asc':
					return a.daily_rate_cents - b.daily_rate_cents;
				case 'rate-desc':
					return b.daily_rate_cents - a.daily_rate_cents;
				case 'stock-desc':
					return b.available_units - a.available_units;
				default:
					return a.name.localeCompare(b.name);
			}
		});
	});

	async function loadProducts() {
		isLoading = true;
		loadError = '';
		try {
			const query = hasRequestedWindow
				? `?start=${encodeURIComponent(new Date(`${requestedStart}T00:00:00`).toISOString())}&end=${encodeURIComponent(new Date(`${requestedEnd}T00:00:00`).toISOString())}`
				: '';
			const response = await fetch(`/api/equipment${query}`);
			if (!response.ok) throw new Error();
			const result = (await response.json()) as { products?: EquipmentProduct[] };
			if (!Array.isArray(result.products)) throw new Error();
			products = result.products;
			if (
				selectedCategory !== 'All equipment' &&
				!products.some((product) => product.category.name === selectedCategory)
			)
				selectedCategory = 'All equipment';
		} catch {
			products = [];
			loadError = 'The equipment catalogue could not be loaded. Please try again.';
		} finally {
			isLoading = false;
		}
	}

	function formatDate(value: string) {
		return new Intl.DateTimeFormat('en-AU', {
			day: 'numeric',
			month: 'short',
			year: 'numeric'
		}).format(new Date(`${value}T00:00:00`));
	}

	function isValidDate(value: string) {
		return (
			/^\d{4}-\d{2}-\d{2}$/.test(value) && !Number.isNaN(new Date(`${value}T00:00:00`).getTime())
		);
	}

	function clearFilters() {
		searchQuery = '';
		selectedCategory = 'All equipment';
		sortOption = 'name-asc';
	}
</script>

<svelte:head><title>Equipment Catalogue · Equipment Hire</title></svelte:head>

<section class="catalog-intro">
	<div class="container page-intro">
		<div>
			<h1>Equipment</h1>
			<p>Browse tools, cleaning equipment, site gear, outdoor equipment, and AV inventory.</p>
		</div>
		<p class="catalogue-summary">
			<strong>{isLoading ? '—' : products.length}</strong> products · Sydney depot
		</p>
	</div>
</section>

<section class="hire-window" aria-label="Hire period context">
	<div class="container window-layout">
		<div class="window-title">
			<span aria-hidden="true">01</span>
			<p><strong>Hire window</strong><small>Dates carried into this catalogue</small></p>
		</div>
		{#if hasRequestedWindow}
			<dl>
				<div>
					<dt>Start</dt>
					<dd>{formatDate(requestedStart)}</dd>
				</div>
				<div>
					<dt>End</dt>
					<dd>{formatDate(requestedEnd)}</dd>
				</div>
				<div>
					<dt>Collection</dt>
					<dd>Sydney depot</dd>
				</div>
			</dl>
			<a href="/home">Change dates</a>
		{:else}
			<p class="window-empty">No dates selected. Quantities show currently operational stock.</p>
			<a href="/home">Choose dates</a>
		{/if}
	</div>
</section>

<section class="container catalogue">
	<details class="mobile-categories">
		<summary>Categories <span>{selectedCategory}</span></summary>
		<div class="category-list">
			<button
				class:active={selectedCategory === 'All equipment'}
				onclick={() => (selectedCategory = 'All equipment')}
				>All equipment <span>{products.length}</span></button
			>
			{#each categoryCounts as category (category.name)}<button
					class:active={selectedCategory === category.name}
					onclick={() => (selectedCategory = category.name)}
					>{category.name} <span>{category.count}</span></button
				>{/each}
		</div>
	</details>

	<aside class="category-index" aria-label="Equipment categories">
		<h2>Categories</h2>
		<button
			class:active={selectedCategory === 'All equipment'}
			onclick={() => (selectedCategory = 'All equipment')}
			><span>All equipment</span><strong>{products.length}</strong></button
		>
		{#each categoryCounts as category (category.name)}<button
				class:active={selectedCategory === category.name}
				onclick={() => (selectedCategory = category.name)}
				><span>{category.name}</span><strong>{category.count}</strong></button
			>{/each}
		<p>
			{hasRequestedWindow
				? 'Availability reflects the selected hire window.'
				: 'Quantities show currently operational stock. Choose dates to check a hire window.'}
		</p>
	</aside>

	<div class="results">
		<div class="catalogue-tools">
			<label
				><span>Search within equipment</span><input
					type="search"
					placeholder="Name, category, or catalogue code"
					bind:value={searchQuery}
					aria-describedby="result-count"
				/></label
			>
			<label
				><span>Sort</span><select bind:value={sortOption}
					><option value="name-asc">Name A–Z</option><option value="rate-asc"
						>Daily rate: low to high</option
					><option value="rate-desc">Daily rate: high to low</option><option value="stock-desc"
						>Most stock available</option
					></select
				></label
			>
		</div>
		<div class="results-heading">
			<p id="result-count" aria-live="polite">
				{#if isLoading}Loading products…{:else}<strong>{filteredProducts.length}</strong>
					{filteredProducts.length === 1 ? 'product' : 'products'}{selectedCategory !==
					'All equipment'
						? ` in ${selectedCategory}`
						: ''}{/if}
			</p>
			{#if searchQuery || selectedCategory !== 'All equipment' || sortOption !== 'name-asc'}<button
					onclick={clearFilters}>Clear filters</button
				>{/if}
		</div>
		{#if isLoading}
			<div class="status-message" aria-live="polite">
				<strong>Loading equipment</strong>
				<p>Checking the catalogue and current availability.</p>
			</div>
		{:else if loadError}
			<div class="status-message error" role="alert">
				<strong>Catalogue unavailable</strong>
				<p>{loadError}</p>
				<button onclick={loadProducts}>Try again</button>
			</div>
		{:else if products.length === 0}
			<div class="status-message">
				<strong>No equipment is currently listed</strong>
				<p>The catalogue has no customer-visible inventory.</p>
			</div>
		{:else if filteredProducts.length > 0}
			<div class="product-grid">
				{#each filteredProducts as product (product.id)}<ToolCard {product} />{/each}
			</div>
		{:else}
			<div class="status-message">
				<strong>No equipment found</strong>
				<p>Try a different search or return to the full catalogue.</p>
				<button onclick={clearFilters}>Show all equipment</button>
			</div>
		{/if}
	</div>
</section>

<style>
	.catalog-intro {
		padding: 2rem 0 1.5rem;
		border-bottom: 1px solid var(--line);
		background: var(--surface);
	}
	.page-intro {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 2rem;
	}
	h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(2rem, 4vw, 2.35rem);
		letter-spacing: -0.035em;
	}
	.page-intro > div > p,
	.catalogue-summary {
		margin: 0.55rem 0 0;
		color: var(--muted);
		font-size: 0.85rem;
	}
	.catalogue-summary {
		white-space: nowrap;
	}
	.catalogue-summary strong {
		color: var(--ink);
		font-size: 1.15rem;
	}
	.hire-window {
		border-bottom: 1px solid var(--line-dark);
		background: var(--ink);
		color: #f4f3ef;
	}
	.window-layout {
		display: flex;
		min-height: 4.75rem;
		align-items: center;
		gap: clamp(1.5rem, 4vw, 4rem);
	}
	.window-title {
		display: flex;
		min-width: 13rem;
		align-items: center;
		gap: 0.8rem;
	}
	.window-title > span {
		color: #d47c66;
		font:
			0.75rem ui-monospace,
			monospace;
	}
	.window-title p {
		display: grid;
		gap: 0.1rem;
		margin: 0;
	}
	.window-title small,
	.window-empty,
	dt {
		color: #adb5b0;
		font-size: 0.72rem;
	}
	.window-layout dl {
		display: grid;
		grid-template-columns: repeat(3, minmax(9rem, 1fr));
		flex: 1;
		margin: 0;
	}
	.window-layout dl div {
		padding: 0.35rem 1.25rem;
		border-left: 1px solid #414744;
	}
	dt,
	dd {
		margin: 0;
	}
	dd {
		margin-top: 0.15rem;
		font-size: 0.85rem;
		font-weight: 650;
	}
	.window-empty {
		flex: 1;
		margin: 0;
	}
	.window-layout > a {
		color: #fff;
		font-size: 0.8rem;
		font-weight: 650;
		white-space: nowrap;
	}
	.catalogue {
		display: grid;
		grid-template-columns: 13rem minmax(0, 1fr);
		gap: clamp(2rem, 4vw, 3.5rem);
		padding-block: 2rem 4rem;
	}
	.category-index {
		position: sticky;
		top: 7.25rem;
		align-self: start;
	}
	.category-index h2 {
		margin: 0 0 0.7rem;
		font-size: 0.82rem;
	}
	.category-index button,
	.category-list button {
		display: flex;
		width: 100%;
		min-height: 2.75rem;
		align-items: center;
		justify-content: space-between;
		gap: 0.75rem;
		padding: 0.55rem 0.65rem;
		border: 0;
		border-bottom: 1px solid var(--line);
		background: transparent;
		color: var(--text);
		font-size: 0.82rem;
		text-align: left;
		cursor: pointer;
	}
	.category-index button:first-of-type {
		border-top: 1px solid var(--line-dark);
	}
	.category-index button:hover,
	.category-index button.active,
	.category-list button:hover,
	.category-list button.active {
		background: var(--surface);
		box-shadow: inset 3px 0 0 var(--brand);
		color: var(--ink);
	}
	.category-index button strong,
	.category-list button span {
		color: var(--muted);
		font-size: 0.75rem;
	}
	.category-index > p {
		margin: 1.25rem 0 0;
		color: var(--muted);
		font-size: 0.72rem;
		line-height: 1.5;
	}
	.mobile-categories {
		display: none;
	}
	.results {
		min-width: 0;
	}
	.catalogue-tools {
		display: grid;
		grid-template-columns: minmax(16rem, 1fr) minmax(13rem, auto);
		align-items: end;
		gap: 1rem;
	}
	.catalogue-tools label {
		display: grid;
		gap: 0.4rem;
		font-size: 0.76rem;
		font-weight: 650;
	}
	.catalogue-tools input,
	.catalogue-tools select {
		height: var(--control-height);
		padding: 0 0.8rem;
		border: 1px solid var(--line-dark);
		background: #fff;
	}
	.results-heading {
		display: flex;
		min-height: 3.4rem;
		align-items: end;
		justify-content: space-between;
		gap: 1rem;
		padding-bottom: 0.75rem;
	}
	.results-heading p {
		margin: 0;
		color: var(--muted);
		font-size: 0.8rem;
	}
	.results-heading strong {
		color: var(--ink);
		font-size: 1rem;
	}
	.results-heading button,
	.status-message button {
		padding: 0.35rem 0;
		border: 0;
		background: transparent;
		color: var(--brand-dark);
		font-size: 0.78rem;
		font-weight: 680;
		text-decoration: underline;
		cursor: pointer;
	}
	.product-grid {
		display: grid;
		grid-template-columns: repeat(5, minmax(0, 1fr));
		column-gap: clamp(0.75rem, 1.4vw, 1.25rem);
	}
	.status-message {
		padding: 3rem 0;
		border-top: 1px solid var(--line-dark);
		color: var(--muted);
	}
	.status-message strong {
		color: var(--ink);
	}
	.status-message p {
		margin: 0.35rem 0;
	}
	.status-message.error {
		color: var(--danger);
	}
	@media (max-width: 1180px) {
		.product-grid {
			grid-template-columns: repeat(4, minmax(0, 1fr));
		}
	}
	@media (max-width: 900px) {
		.product-grid {
			grid-template-columns: repeat(3, minmax(0, 1fr));
		}
		.catalogue {
			grid-template-columns: 1fr;
		}
		.category-index {
			display: none;
		}
		.mobile-categories {
			display: block;
		}
	}
	@media (max-width: 680px) {
		.page-intro {
			align-items: start;
			flex-direction: column;
			gap: 0.5rem;
		}
		.window-layout {
			align-items: start;
			flex-wrap: wrap;
			padding-block: 1rem;
		}
		.window-title {
			width: 100%;
		}
		.window-layout dl {
			grid-template-columns: repeat(2, 1fr);
			width: 100%;
		}
		.window-layout dl div {
			padding-left: 0;
			border-left: 0;
		}
		.catalogue-tools {
			grid-template-columns: 1fr;
		}
		.product-grid {
			grid-template-columns: repeat(2, minmax(0, 1fr));
		}
	}
	@media (max-width: 480px) {
		.product-grid {
			grid-template-columns: 1fr;
		}
	}
</style>
