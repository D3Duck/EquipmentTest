<script lang="ts">
	import type { Tool } from '#lib/types.ts';

	let { product }: { product: Tool } = $props();
	let imageFailed = $state(false);

	const currency = new Intl.NumberFormat('en-AU', {
		style: 'currency',
		currency: 'AUD',
		maximumFractionDigits: 0
	});

	const stockState = $derived(
		product.availableUnits === 0 ? 'unavailable' : product.availableUnits <= 1 ? 'low' : 'available'
	);
</script>

<article class="tool-entry">
	<div class="product-image">
		{#if imageFailed}
			<div class="image-fallback" role="img" aria-label={`Image unavailable for ${product.name}`}>
				<span>Image unavailable</span>
				<code>{product.assetCode}</code>
			</div>
		{:else}
			<img
				src={product.imageUrl}
				alt={product.name}
				width="1200"
				height="896"
				loading="lazy"
				onerror={() => (imageFailed = true)}
			/>
		{/if}
	</div>

	<div class="entry-content">
		<p class="product-meta">
			<span>{product.category}</span>
			<code>{product.assetCode}</code>
		</p>
		<h2>{product.name}</h2>
		<p class="description">{product.description}</p>

		<div class="stock-line">
			<span>Current demo stock</span>
			<strong class:low={stockState === 'low'} class:unavailable={stockState === 'unavailable'}>
				{product.availableUnits} / {product.totalUnits} available
			</strong>
		</div>

		<div class="entry-footer">
			<p class="rate">
				<strong>{currency.format(product.dailyRateCents / 100)}</strong>
				<span>per day</span>
			</p>
			<a href={`/equipment/products/${product.id}`}>View item <span aria-hidden="true">→</span></a>
		</div>
	</div>
</article>

<style>
	.tool-entry {
		display: flex;
		height: 100%;
		min-width: 0;
		flex-direction: column;
		padding: 1rem 0 1.5rem;
		border-top: 1px solid var(--line-dark);
	}

	.product-image {
		position: relative;
		aspect-ratio: 4 / 3;
		overflow: hidden;
		border: 1px solid var(--line);
		background: #eef0ef;
	}

	.product-image::after {
		position: absolute;
		top: 0;
		left: 0;
		width: 3px;
		height: 2.25rem;
		background: var(--brand);
		content: '';
	}

	.product-image img {
		display: block;
		width: 100%;
		height: 100%;
		object-fit: contain;
	}

	.image-fallback {
		display: grid;
		height: 100%;
		place-content: center;
		gap: 0.3rem;
		color: var(--muted);
		font-size: 0.76rem;
		text-align: center;
	}

	.image-fallback code {
		color: var(--ink);
		font-size: 0.72rem;
	}

	.entry-content {
		display: flex;
		flex: 1;
		flex-direction: column;
		padding-top: 0.9rem;
	}

	.product-meta {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		margin: 0 0 0.45rem;
		color: var(--muted);
		font-size: 0.75rem;
	}

	.product-meta code {
		color: var(--ink);
		font-family: ui-monospace, monospace;
		font-size: 0.72rem;
	}

	h2 {
		margin: 0;
		color: var(--ink);
		font-size: 1.13rem;
		font-weight: 680;
		letter-spacing: -0.015em;
		line-height: 1.25;
	}

	.description {
		margin: 0.55rem 0 0;
		color: var(--muted);
		font-size: 0.86rem;
		line-height: 1.55;
	}

	.stock-line {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 0.75rem;
		margin-top: 1rem;
		padding: 0.65rem 0;
		border-top: 1px solid var(--line);
		border-bottom: 1px solid var(--line);
		font-size: 0.73rem;
	}

	.stock-line > span {
		color: var(--muted);
	}

	.stock-line strong {
		color: var(--available);
		font-weight: 720;
		font-variant-numeric: tabular-nums;
		text-align: right;
	}

	.stock-line strong.low {
		color: var(--warning);
	}

	.stock-line strong.unavailable {
		color: var(--danger);
	}

	.entry-footer {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 1rem;
		margin-top: auto;
		padding-top: 0.85rem;
	}

	.rate {
		display: flex;
		align-items: baseline;
		gap: 0.35rem;
		margin: 0;
		font-variant-numeric: tabular-nums;
	}

	.rate strong {
		color: var(--ink);
		font-size: 1.25rem;
		letter-spacing: -0.025em;
	}

	.rate span,
	.entry-footer > a {
		color: var(--muted);
		font-size: 0.72rem;
	}

	.entry-footer > a {
		color: var(--brand-dark);
		font-weight: 680;
		text-underline-offset: 0.2rem;
	}

	@media (max-width: 540px) {
		.tool-entry {
			display: grid;
			grid-template-columns: minmax(7.5rem, 38%) 1fr;
			gap: 1rem;
			padding: 1rem 0;
		}

		.product-image {
			aspect-ratio: 1 / 1;
		}

		.entry-content {
			padding: 0;
		}

		.description {
			display: -webkit-box;
			overflow: hidden;
			-webkit-box-orient: vertical;
			-webkit-line-clamp: 3;
			line-clamp: 3;
		}

		.stock-line {
			display: grid;
			gap: 0.2rem;
		}

		.stock-line strong {
			text-align: left;
		}
	}
</style>
