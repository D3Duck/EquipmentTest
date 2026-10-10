<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import type { EquipmentProduct } from '#lib/types.ts';

	let product = $state<EquipmentProduct | null>(null);
	let isLoading = $state(true);
	let isChecking = $state(false);
	let loadError = $state('');
	let availabilityError = $state('');
	let startDate = $state(page.url.searchParams.get('start') ?? '');
	let endDate = $state(page.url.searchParams.get('end') ?? '');
	let checkedStartDate = $state('');
	let checkedEndDate = $state('');
	let quantity = $state(1);
	let selectedImageIndex = $state(0);
	let imageFailed = $state(false);

	const currency = new Intl.NumberFormat('en-AU', {
		style: 'currency',
		currency: 'AUD',
		maximumFractionDigits: 0
	});
	const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone || 'local time';
	const minimumEndDate = $derived(startDate ? nextDate(startDate) : undefined);
	const selectionIsChecked = $derived(
		Boolean(product?.availability_period) &&
			startDate === checkedStartDate &&
			endDate === checkedEndDate
	);
	const availableForSelection = $derived(
		product ? (selectionIsChecked ? product.available_units : product.operational_units) : 0
	);
	const hireDays = $derived(
		validDateRange(startDate, endDate) ? daysBetween(startDate, endDate) : 0
	);
	const estimatedTotal = $derived(product ? product.daily_rate_cents * quantity * hireDays : 0);
	const selectedImage = $derived(product?.images[selectedImageIndex] ?? null);
	const specificationEntries = $derived(Object.entries(product?.specifications ?? {}));
	const catalogueHref = $derived.by(() => {
		const query = dateQuery(startDate, endDate);
		return `/equipment${query ? `?${query}` : ''}`;
	});

	onMount(() => {
		const includePeriod = validDateRange(startDate, endDate);
		void loadProduct(includePeriod);
	});

	async function loadProduct(includePeriod: boolean) {
		if (product) isChecking = true;
		else isLoading = true;
		loadError = '';
		availabilityError = '';

		const productID = page.params.id;
		if (!productID) {
			loadError = 'This equipment product could not be found.';
			isLoading = false;
			isChecking = false;
			return;
		}

		let requestURL = `/api/equipment/products/${encodeURIComponent(productID)}`;
		if (includePeriod) {
			requestURL += `?${dateQuery(localDateToUTC(startDate), localDateToUTC(endDate))}`;
		}

		try {
			const response = await fetch(requestURL, { headers: { Accept: 'application/json' } });
			const result = await response.json().catch(() => null);
			if (!response.ok) {
				throw new Error(
					response.status === 404
						? 'This equipment product could not be found.'
						: (result?.error ?? 'The equipment product could not be loaded.')
				);
			}

			product = result.product as EquipmentProduct;
			selectedImageIndex = 0;
			imageFailed = false;
			if (includePeriod) {
				checkedStartDate = startDate;
				checkedEndDate = endDate;
			}
			quantity = Math.max(1, quantity);
		} catch (error) {
			const message =
				error instanceof Error ? error.message : 'The equipment product could not be loaded.';
			if (product) availabilityError = message;
			else loadError = message;
		} finally {
			isLoading = false;
			isChecking = false;
		}
	}

	function checkAvailability(event: SubmitEvent) {
		event.preventDefault();
		availabilityError = '';
		if (!startDate || !endDate) {
			availabilityError = 'Choose both a start date and an end date.';
			return;
		}
		if (!validDateRange(startDate, endDate)) {
			availabilityError = 'The end date must be later than the start date.';
			return;
		}
		void loadProduct(true);
	}

	function selectImage(index: number) {
		selectedImageIndex = index;
		imageFailed = false;
	}

	function nextDate(value: string) {
		if (!isValidDate(value)) return undefined;
		const [year, month, day] = value.split('-').map(Number);
		return new Date(Date.UTC(year, month - 1, day + 1)).toISOString().slice(0, 10);
	}

	function isValidDate(value: string) {
		if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
		return !Number.isNaN(Date.parse(`${value}T00:00:00Z`));
	}

	function validDateRange(start: string, end: string) {
		return isValidDate(start) && isValidDate(end) && end > start;
	}

	function daysBetween(start: string, end: string) {
		return Math.round(
			(Date.parse(`${end}T00:00:00Z`) - Date.parse(`${start}T00:00:00Z`)) / 86_400_000
		);
	}

	function localDateToUTC(value: string) {
		return new Date(`${value}T00:00:00`).toISOString();
	}

	function dateQuery(start: string, end: string) {
		return [
			start ? `start=${encodeURIComponent(start)}` : '',
			end ? `end=${encodeURIComponent(end)}` : ''
		]
			.filter(Boolean)
			.join('&');
	}

	function formatSpecificationName(value: string) {
		return value.replaceAll('_', ' ').replace(/^\w/, (letter) => letter.toUpperCase());
	}
</script>

<svelte:head>
	<title
		>{product ? `${product.name} · Equipment Hire` : 'Equipment product · Equipment Hire'}</title
	>
	<meta
		name="description"
		content={product?.description ?? 'Equipment details, daily rate, and hire availability.'}
	/>
</svelte:head>

<div class="product-page">
	<nav class="container breadcrumb" aria-label="Breadcrumb">
		<a href="/home">Home</a><span aria-hidden="true">/</span><a href={catalogueHref}>Equipment</a>
		{#if product}<span aria-hidden="true">/</span><span>{product.catalogue_code}</span>{/if}
	</nav>

	{#if isLoading}
		<section class="container page-state" aria-live="polite">
			<p class="state-index">Loading</p>
			<h1>Loading equipment details…</h1>
			<p>Checking the current product information and stock.</p>
		</section>
	{:else if loadError || !product}
		<section class="container page-state error-state" role="alert">
			<p class="state-index">Unable to load</p>
			<h1>Equipment details unavailable</h1>
			<p>{loadError || 'This equipment product is unavailable.'}</p>
			<div class="state-actions">
				<button type="button" onclick={() => loadProduct(false)}>Try again</button>
				<a href="/equipment">Return to equipment</a>
			</div>
		</section>
	{:else}
		<section class="container product-layout">
			<div class="gallery" aria-label={`${product.name} images`}>
				<div class="primary-image">
					{#if selectedImage && !imageFailed}
						<img
							src={selectedImage.path}
							alt={selectedImage.alt_text}
							width="1200"
							height="896"
							onerror={() => (imageFailed = true)}
						/>
					{:else}
						<div
							class="image-fallback"
							role="img"
							aria-label={`Image unavailable for ${product.name}`}
						>
							<span>Image unavailable</span>
							<code>{product.catalogue_code}</code>
						</div>
					{/if}
				</div>

				{#if product.images.length > 1}
					<div class="thumbnail-list" aria-label="Choose product image">
						{#each product.images as image, index (image.id)}
							<button
								type="button"
								class:active={selectedImageIndex === index}
								aria-label={`Show image ${index + 1} of ${product.name}`}
								aria-pressed={selectedImageIndex === index}
								onclick={() => selectImage(index)}
							>
								<img src={image.path} alt="" width="160" height="120" />
							</button>
						{/each}
					</div>
				{/if}
			</div>

			<div class="product-information">
				<p class="product-meta">
					<span>{product.category.name}</span><code>{product.catalogue_code}</code>
				</p>
				<h1>{product.name}</h1>
				<p class="description">{product.description}</p>

				<div class="rate-ledger">
					<div>
						<span>Daily rate</span>
						<strong>{currency.format(product.daily_rate_cents / 100)}</strong>
					</div>
					<div>
						<span>Current operational stock</span>
						<strong>{product.operational_units} of {product.total_units}</strong>
					</div>
				</div>

				<form class="hire-panel" onsubmit={checkAvailability}>
					<div class="panel-heading">
						<span aria-hidden="true">01</span>
						<div>
							<h2>Configure this hire</h2>
							<p>Dates use {timeZone}. The end date is the return boundary.</p>
						</div>
					</div>

					<div class="hire-fields">
						<label>
							<span>Start date</span>
							<input name="start" type="date" bind:value={startDate} required />
						</label>
						<label>
							<span>End date</span>
							<input name="end" type="date" min={minimumEndDate} bind:value={endDate} required />
						</label>
						<label>
							<span>Quantity</span>
							<input
								name="quantity"
								type="number"
								min="1"
								max={Math.max(availableForSelection, 1)}
								bind:value={quantity}
								required
							/>
						</label>
					</div>

					{#if availabilityError}
						<p class="form-message error-message" role="alert">{availabilityError}</p>
					{:else if selectionIsChecked}
						<p
							class:unavailable={product.available_units === 0 ||
								quantity > product.available_units}
							class="form-message availability-message"
							aria-live="polite"
						>
							{#if product.available_units === 0}
								<strong>Unavailable</strong> for the selected hire period.
							{:else if quantity > product.available_units}
								<strong>Only {product.available_units} available.</strong> Reduce the requested quantity.
							{:else}
								<strong>{product.available_units} available</strong> for the selected hire period.
							{/if}
						</p>
					{:else}
						<p class="form-message" aria-live="polite">
							Check the selected dates before continuing. Catalogue stock does not reserve an item.
						</p>
					{/if}

					<div class="hire-summary">
						<div>
							<span>Estimated hire</span>
							<strong
								>{hireDays > 0 ? `${hireDays} ${hireDays === 1 ? 'day' : 'days'}` : '—'}</strong
							>
						</div>
						<div>
							<span>Estimated total</span>
							<strong>{hireDays > 0 ? currency.format(estimatedTotal / 100) : '—'}</strong>
						</div>
					</div>

					<button class="check-button" type="submit" disabled={isChecking}>
						{isChecking ? 'Checking availability…' : 'Check availability'}
					</button>
					<p class="basket-note">
						Online basket checkout is not yet available in this demo. Checking availability does not
						reserve equipment.
					</p>
				</form>
			</div>
		</section>

		<section class="container product-details">
			<div class="detail-section specifications">
				<p class="section-index">02</p>
				<h2>Specifications</h2>
				{#if specificationEntries.length > 0}
					<dl>
						{#each specificationEntries as [name, value] (name)}
							<div>
								<dt>{formatSpecificationName(name)}</dt>
								<dd>{value}</dd>
							</div>
						{/each}
					</dl>
				{:else}
					<p>No technical specifications are listed for this product.</p>
				{/if}
			</div>

			<div class="detail-section terms">
				<p class="section-index">03</p>
				<h2>Hire and collection</h2>
				<p>{product.hire_terms ?? 'Standard depot hire terms apply.'}</p>
				<dl>
					<div>
						<dt>Collection</dt>
						<dd>Sydney depot</dd>
					</div>
					<div>
						<dt>Identification</dt>
						<dd>Photo ID required</dd>
					</div>
					<div>
						<dt>Returns</dt>
						<dd>Before depot closing time</dd>
					</div>
				</dl>
			</div>
		</section>
	{/if}
</div>

<style>
	.product-page {
		padding-bottom: 4rem;
	}

	.breadcrumb {
		display: flex;
		min-height: 3.25rem;
		align-items: center;
		gap: 0.55rem;
		border-bottom: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.76rem;
	}

	.breadcrumb a {
		color: var(--ink);
		text-underline-offset: 0.2rem;
	}

	.page-state {
		min-height: 28rem;
		padding-block: clamp(3rem, 8vw, 7rem);
	}

	.state-index,
	.section-index {
		margin: 0 0 0.6rem;
		color: var(--brand-dark);
		font-family: ui-monospace, monospace;
		font-size: 0.72rem;
		font-weight: 700;
		text-transform: uppercase;
	}

	.page-state h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(2rem, 5vw, 3rem);
		letter-spacing: -0.04em;
	}

	.page-state > p:not(.state-index) {
		max-width: 36rem;
		color: var(--muted);
	}

	.state-actions {
		display: flex;
		gap: 1rem;
		margin-top: 1.5rem;
	}

	.state-actions button,
	.state-actions a {
		display: inline-flex;
		min-height: 2.75rem;
		align-items: center;
		padding: 0.55rem 0.9rem;
		border: 1px solid var(--line-dark);
		background: var(--surface);
		color: var(--ink);
		font-weight: 680;
		text-decoration: none;
		cursor: pointer;
	}

	.product-layout {
		display: grid;
		grid-template-columns: minmax(16rem, 22rem) minmax(0, 1fr);
		align-items: start;
		gap: clamp(2rem, 4vw, 4rem);
		padding-block: clamp(1.75rem, 3vw, 2.75rem);
	}

	.gallery,
	.product-information {
		min-width: 0;
	}

	.gallery {
		width: 100%;
		max-width: 22rem;
	}

	.primary-image {
		display: grid;
		aspect-ratio: 4 / 3;
		place-items: center;
		border: 1px solid var(--line-dark);
		background: #eef0ef;
	}

	.primary-image img {
		display: block;
		width: 100%;
		height: 100%;
		object-fit: contain;
	}

	.image-fallback {
		display: grid;
		place-items: center;
		gap: 0.35rem;
		color: var(--muted);
		font-size: 0.8rem;
	}

	.image-fallback code {
		color: var(--ink);
	}

	.thumbnail-list {
		display: flex;
		gap: 0.6rem;
		margin-top: 0.75rem;
	}

	.thumbnail-list button {
		width: 5rem;
		padding: 0.2rem;
		border: 1px solid var(--line);
		background: var(--surface);
		cursor: pointer;
	}

	.thumbnail-list button.active {
		border-color: var(--brand);
		box-shadow: inset 0 -3px 0 var(--brand);
	}

	.thumbnail-list img {
		display: block;
		width: 100%;
		aspect-ratio: 4 / 3;
		object-fit: contain;
	}

	.product-meta {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 1rem;
		margin: 0 0 0.65rem;
		color: var(--muted);
		font-size: 0.76rem;
		text-transform: uppercase;
	}

	.product-meta code {
		color: var(--ink);
		font-size: 0.75rem;
	}

	.product-information > h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(2rem, 3.25vw, 2.65rem);
		font-weight: 720;
		letter-spacing: -0.04em;
		line-height: 1.05;
	}

	.description {
		max-width: 42rem;
		margin: 1rem 0 0;
		color: var(--muted);
		font-size: 0.98rem;
		line-height: 1.65;
	}

	.rate-ledger {
		display: grid;
		grid-template-columns: 1fr 1fr;
		margin-top: 1.5rem;
		border-top: 1px solid var(--line-dark);
		border-bottom: 1px solid var(--line-dark);
	}

	.rate-ledger > div {
		display: grid;
		gap: 0.25rem;
		padding: 0.8rem 1rem 0.8rem 0;
	}

	.rate-ledger > div + div {
		padding-left: 1rem;
		border-left: 1px solid var(--line);
	}

	.rate-ledger span,
	.hire-summary span {
		color: var(--muted);
		font-size: 0.7rem;
	}

	.rate-ledger strong {
		color: var(--ink);
		font-size: 1.2rem;
		font-variant-numeric: tabular-nums;
	}

	.hire-panel {
		margin-top: 1.5rem;
		padding: 1.2rem;
		border: 1px solid var(--line-dark);
		border-top: 4px solid var(--brand);
		background: var(--surface);
	}

	.panel-heading {
		display: flex;
		gap: 0.75rem;
		padding-bottom: 0.85rem;
		border-bottom: 1px solid var(--line);
	}

	.panel-heading > span {
		color: var(--brand-dark);
		font-family: ui-monospace, monospace;
		font-size: 0.7rem;
	}

	.panel-heading h2 {
		margin: 0;
		color: var(--ink);
		font-size: 1.1rem;
	}

	.panel-heading p {
		margin: 0.25rem 0 0;
		color: var(--muted);
		font-size: 0.72rem;
	}

	.hire-fields {
		display: grid;
		grid-template-columns: 1fr 1fr 0.65fr;
		gap: 0.65rem;
		margin-top: 0.9rem;
	}

	.hire-fields label {
		display: grid;
		gap: 0.35rem;
		color: var(--ink);
		font-size: 0.72rem;
		font-weight: 680;
	}

	.hire-fields input {
		width: 100%;
		height: var(--control-height);
		padding: 0 0.55rem;
		border: 1px solid var(--line-dark);
		background: #fff;
		color: var(--ink);
		font-variant-numeric: tabular-nums;
	}

	.form-message {
		margin: 0.85rem 0 0;
		padding: 0.65rem 0;
		border-top: 1px solid var(--line);
		border-bottom: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.76rem;
	}

	.availability-message strong {
		color: var(--available);
	}

	.availability-message.unavailable,
	.availability-message.unavailable strong,
	.error-message {
		color: var(--danger);
	}

	.hire-summary {
		display: grid;
		grid-template-columns: 1fr 1fr;
		margin-top: 0.85rem;
	}

	.hire-summary > div {
		display: grid;
		gap: 0.2rem;
	}

	.hire-summary strong {
		font-variant-numeric: tabular-nums;
	}

	.check-button {
		width: 100%;
		min-height: 3.2rem;
		margin-top: 1rem;
		border: 1px solid var(--brand-dark);
		background: var(--brand);
		color: #fff;
		font-weight: 720;
		cursor: pointer;
	}

	.check-button:hover:not(:disabled) {
		background: var(--brand-dark);
	}

	.check-button:disabled {
		cursor: wait;
		opacity: 0.7;
	}

	.basket-note {
		margin: 0.65rem 0 0;
		color: var(--muted);
		font-size: 0.68rem;
		line-height: 1.45;
	}

	.product-details {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: clamp(2rem, 6vw, 5rem);
		padding-top: 2rem;
		border-top: 1px solid var(--line-dark);
	}

	.detail-section h2 {
		margin: 0;
		color: var(--ink);
		font-size: 1.25rem;
	}

	.detail-section > p:not(.section-index) {
		color: var(--muted);
		line-height: 1.6;
	}

	.detail-section dl {
		margin: 1rem 0 0;
		border-top: 1px solid var(--ink);
	}

	.detail-section dl div {
		display: grid;
		grid-template-columns: minmax(8rem, 0.75fr) 1fr;
		gap: 1rem;
		padding: 0.7rem 0;
		border-bottom: 1px solid var(--line);
	}

	.detail-section dt {
		color: var(--muted);
		font-size: 0.76rem;
	}

	.detail-section dd {
		margin: 0;
		color: var(--ink);
		font-size: 0.82rem;
		font-weight: 650;
		text-align: right;
	}

	@media (max-width: 820px) {
		.product-layout {
			grid-template-columns: 1fr;
		}

		.gallery {
			max-width: 18rem;
		}
	}

	@media (max-width: 620px) {
		.product-page {
			padding-bottom: 3rem;
		}

		.product-layout,
		.product-details {
			gap: 1.5rem;
		}

		.gallery {
			max-width: 14rem;
		}

		.product-details,
		.hire-fields {
			grid-template-columns: 1fr;
		}

		.rate-ledger {
			grid-template-columns: 1fr;
		}

		.rate-ledger > div + div {
			padding-left: 0;
			border-top: 1px solid var(--line);
			border-left: 0;
		}

		.detail-section dl div {
			grid-template-columns: 1fr;
			gap: 0.2rem;
		}

		.detail-section dd {
			text-align: left;
		}
	}
</style>
