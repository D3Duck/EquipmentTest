<script lang="ts">
	import type { Tool } from '#lib/types.ts';

	let { product }: { product: Tool } = $props();

	const currency = new Intl.NumberFormat('en-AU', {
		style: 'currency',
		currency: 'AUD',
		maximumFractionDigits: 0
	});
</script>

<article class="tool-card">
	<div class="product-image">
		<img src={product.imageUrl} alt={product.name} width="1200" height="896" loading="lazy" />
		<span>{product.category}</span>
	</div>

	<div class="card-content">
		<p class="asset-code">{product.assetCode} / Sydney depot</p>
		<h2>{product.name}</h2>
		<p class="description">{product.description}</p>

		<div class="card-footer">
			<p class="rate">
				<strong>{currency.format(product.dailyRateCents / 100)}</strong>
				<span>per day</span>
			</p>
			<p class:low-stock={product.availableUnits <= 1} class="availability">
				{product.availableUnits} of {product.totalUnits} available
			</p>
		</div>
	</div>
</article>

<style>
	.tool-card {
		display: flex;
		height: 100%;
		width: 100%;
		flex-direction: column;
		overflow: hidden;
		border: 1px solid var(--ink);
		border-top: 5px solid var(--brand);
		border-radius: var(--radius-md);
		background: var(--surface);
	}

	.product-image {
		position: relative;
		aspect-ratio: 4 / 3;
		overflow: hidden;
		border-bottom: 1px solid var(--ink);
		background: #e6e3db;
	}

	.product-image img {
		display: block;
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.product-image span {
		position: absolute;
		top: 0.7rem;
		left: 0.7rem;
		padding: 0.3rem 0.45rem;
		border: 1px solid var(--ink);
		background: #f0c84b;
		color: var(--ink);
		font-size: 0.68rem;
		font-weight: 800;
		letter-spacing: 0.08em;
		text-transform: uppercase;
	}

	.card-content {
		display: flex;
		flex: 1;
		flex-direction: column;
		padding: 1.15rem;
	}

	.asset-code {
		margin: 0 0 0.55rem;
		color: var(--brand-dark);
		font-family: ui-monospace, monospace;
		font-size: 0.7rem;
		font-weight: 750;
		letter-spacing: 0.06em;
		text-transform: uppercase;
	}

	h2 {
		margin: 0 0 0.6rem;
		color: var(--ink);
		font-size: 1.15rem;
		line-height: 1.2;
	}

	.description {
		margin: 0;
		color: var(--muted);
		font-size: 0.86rem;
		line-height: 1.6;
	}

	.card-footer {
		display: flex;
		align-items: end;
		justify-content: space-between;
		gap: 1rem;
		margin-top: auto;
		padding-top: 1.25rem;
	}

	.rate {
		display: grid;
		gap: 0.1rem;
		margin: 0;
	}

	.rate strong {
		color: var(--ink);
		font-family: ui-monospace, monospace;
		font-size: 1.2rem;
	}

	.rate span,
	.availability {
		color: var(--muted);
		font-size: 0.7rem;
	}

	.availability {
		margin: 0;
		color: #376b43;
		font-weight: 750;
		text-align: right;
	}

	.availability.low-stock {
		color: #a84b1f;
	}
</style>
