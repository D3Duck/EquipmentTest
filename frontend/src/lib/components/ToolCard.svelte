<script lang="ts">
	import { page } from '$app/state';
	import type { EquipmentProduct } from '#lib/types.ts';

	let { product }: { product: EquipmentProduct } = $props();
	let imageFailed = $state(false);

	const currency = new Intl.NumberFormat('en-AU', {
		style: 'currency',
		currency: 'AUD',
		maximumFractionDigits: 0
	});

	const stockState = $derived(
		product.available_units === 0
			? 'unavailable'
			: product.available_units <= 1
				? 'low'
				: 'available'
	);
	const primaryImage = $derived(product.images[0]);
	const productHref = $derived.by(() => {
		const start = page.url.searchParams.get('start');
		const end = page.url.searchParams.get('end');
		const query = [
			start ? `start=${encodeURIComponent(start)}` : '',
			end ? `end=${encodeURIComponent(end)}` : ''
		]
			.filter(Boolean)
			.join('&');
		return `/equipment/products/${product.id}${query ? `?${query}` : ''}`;
	});
</script>

<article class="tool-entry">
	<div class="product-image">
		{#if imageFailed || !primaryImage}
			<div class="image-fallback" role="img" aria-label={`Image unavailable for ${product.name}`}>
				<span>Image unavailable</span>
				<code>{product.catalogue_code}</code>
			</div>
		{:else if primaryImage}
			<a href={productHref}>
				<img
					src={primaryImage.path}
					alt={primaryImage.alt_text || product.name}
					width="1200"
					height="896"
					loading="lazy"
					onerror={() => (imageFailed = true)}
				/>
			</a>
		{/if}
	</div>

	<div class="entry-content">
		<p class="product-meta">
			<span>{product.category.name}</span>
			<code>{product.catalogue_code}</code>
		</p>
		<h2>{product.name}</h2>

		<div class="stock-line">
			<span>{product.availability_period ? 'Hire-window stock' : 'Operational stock'}</span>
			<strong class:low={stockState === 'low'} class:unavailable={stockState === 'unavailable'}>
				{product.available_units} / {product.total_units} available
			</strong>
		</div>

		<div class="entry-footer">
			<p class="rate">
				<strong>{currency.format(product.daily_rate_cents / 100)}</strong>
				<span>per day</span>
			</p>
			<a href={productHref}>View item <span aria-hidden="true">→</span></a>
		</div>
	</div>
</article>

<style>
	.tool-entry {
		display: flex;
		height: 100%;
		min-width: 0;
		flex-direction: column;
		padding: 0.75rem 0 1rem;
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
		padding-top: 0.65rem;
	}

	.product-meta {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		margin: 0 0 0.35rem;
		color: var(--muted);
		font-size: 0.68rem;
	}

	.product-meta code {
		color: var(--ink);
		font-family: ui-monospace, monospace;
		font-size: 0.68rem;
	}

	h2 {
		margin: 0;
		color: var(--ink);
		font-size: 0.98rem;
		font-weight: 680;
		letter-spacing: -0.015em;
		line-height: 1.25;
	}

	.stock-line {
		display: grid;
		gap: 0.15rem;
		margin-top: 0.7rem;
		padding: 0.5rem 0;
		border-top: 1px solid var(--line);
		border-bottom: 1px solid var(--line);
		font-size: 0.68rem;
	}

	.stock-line > span {
		color: var(--muted);
	}

	.stock-line strong {
		color: var(--available);
		font-weight: 720;
		font-variant-numeric: tabular-nums;
		text-align: left;
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
		gap: 0.5rem;
		margin-top: auto;
		padding-top: 0.65rem;
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
		font-size: 1.08rem;
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

	@media (max-width: 480px) {
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

		.stock-line {
			display: grid;
			gap: 0.2rem;
		}

		.stock-line strong {
			text-align: left;
		}
	}
</style>
