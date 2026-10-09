<script lang="ts">
	import { afterNavigate } from '$app/navigation';
	import { page } from '$app/state';
	import ToolCard from '#lib/components/ToolCard.svelte';
	import type { Tool, ToolCategory } from '#lib/types.ts';

	const products: Tool[] = [
		{
			id: '5fa1f462-6810-4d06-88bd-057ad459991d',
			name: '18V Cordless Drill Kit',
			description:
				'General-purpose drill and driver with two batteries, charger, and a 25-piece bit set.',
			photoID: 'ec39c30c-5b42-48f1-bcc9-90464f42dc2c',
			imageUrl: '/images/products/Cordless_drill_with_drill-bit_case_20261007221651.jpg',
			assetCode: 'TL-014',
			category: 'Tools',
			dailyRateCents: 2800,
			availableUnits: 3,
			totalUnits: 4
		},
		{
			id: 'ec8f22d3-7ad2-4d10-8302-582e6172fd94',
			name: '185mm Circular Saw',
			description:
				'Corded circular saw for framing and sheet timber, supplied with a general-purpose blade and guide.',
			photoID: '8bd4b52f-8826-4f8f-88b9-ab6921a45fc3',
			imageUrl: '/images/products/Portable_electric_circular_saw_20261007221651.jpg',
			assetCode: 'CT-022',
			category: 'Tools',
			dailyRateCents: 3500,
			availableUnits: 2,
			totalUnits: 3
		},
		{
			id: '3c725698-5f68-437a-94ee-9aa8c43ece17',
			name: '125mm Angle Grinder',
			description:
				'Compact grinder for cutting, grinding, and surface preparation. Guard and side handle included.',
			photoID: '3785fc92-a2fc-43ea-a782-c9db24647415',
			imageUrl: '/images/products/Electric_angle_grinder_on_display_20261007221651.jpg',
			assetCode: 'MT-031',
			category: 'Tools',
			dailyRateCents: 2600,
			availableUnits: 4,
			totalUnits: 5
		},
		{
			id: 'f21178e3-9b99-4510-9538-4aebf3e9ca36',
			name: 'SDS+ Rotary Hammer',
			description:
				'Heavy-duty rotary hammer for drilling concrete and masonry up to 26mm. Case and masonry bit included.',
			photoID: '4322b774-29a0-4cf5-9db6-9aa1d6f02e21',
			imageUrl: '/images/products/Rotary_hammer_drill_with_bit_20261007221651.jpg',
			assetCode: 'DM-006',
			category: 'Tools',
			dailyRateCents: 4200,
			availableUnits: 1,
			totalUnits: 2
		},
		{
			id: 'cb37fcc0-37b8-4fad-bd0b-89a5fd928df7',
			name: '3000 PSI Pressure Washer',
			description:
				'Petrol pressure washer with hose, spray wand, and interchangeable nozzles for heavy outdoor cleaning.',
			photoID: '6eca381e-9096-46c6-836b-57234573493e',
			imageUrl: '/images/products/Upright_pressure_washer_with_hose_20261007221651.jpg',
			assetCode: 'CL-008',
			category: 'Cleaning',
			dailyRateCents: 6800,
			availableUnits: 3,
			totalUnits: 4
		},
		{
			id: '8ad0d35f-485e-48fa-9ce5-9de631e27eb4',
			name: '35L Wet & Dry Vacuum',
			description:
				'Commercial vacuum for workshop dust, renovation debris, and liquid spills, with floor and crevice tools.',
			photoID: '904e3028-fbd0-4fad-8686-da43c4ed0db1',
			imageUrl: '/images/products/Wet-and-dry_vacuum_cleaner_with_…_20261007221651.jpg',
			assetCode: 'CL-012',
			category: 'Cleaning',
			dailyRateCents: 3800,
			availableUnits: 4,
			totalUnits: 5
		},
		{
			id: '5d43773f-c516-40e5-88fb-682b7ed76af8',
			name: 'Commercial Carpet Cleaner',
			description:
				'Upright extraction cleaner for carpets and rugs, supplied with an upholstery hand tool.',
			photoID: '7a65436e-6d0b-46eb-9ab9-ee2d1ceadcd8',
			imageUrl: '/images/products/Carpet_cleaning_machine_product_…_20261007221651.jpg',
			assetCode: 'CL-019',
			category: 'Cleaning',
			dailyRateCents: 5200,
			availableUnits: 2,
			totalUnits: 3
		},
		{
			id: '98a8b8bb-d63d-43b2-8cee-77758d093c74',
			name: 'Orbital Floor Sander',
			description:
				'Professional floor sander for timber restoration and finishing, with dust bag and extension lead.',
			photoID: 'f41ac7ad-8fe4-49af-8224-86066577fd53',
			imageUrl: '/images/products/Floor_sander_on_grey_background_20261007221651.jpg',
			assetCode: 'FL-004',
			category: 'Cleaning',
			dailyRateCents: 8600,
			availableUnits: 1,
			totalUnits: 2
		},
		{
			id: '39990bed-d17b-46c0-ae31-ce110ee7d2c4',
			name: '460mm Electric Lawn Mower',
			description:
				'Quiet electric mower for small and medium lawns, with adjustable cutting height and grass catcher.',
			photoID: 'eb5db9e5-55f9-49a6-92cb-b493280db6d1',
			imageUrl: '/images/products/Electric_lawn_mower_product_phot…_20261007221651.jpg',
			assetCode: 'GD-005',
			category: 'Garden',
			dailyRateCents: 4600,
			availableUnits: 3,
			totalUnits: 4
		},
		{
			id: '7a372508-c79a-48c9-ad98-dd49bbfa00af',
			name: '600mm Cordless Hedge Trimmer',
			description:
				'Battery hedge trimmer with rotating rear handle, blade guard, charger, and one spare battery.',
			photoID: '8de070e7-038f-4519-b4dc-70cb923b6979',
			imageUrl: '/images/products/Cordless_hedge_trimmer_resting_b…_20261007221651.jpg',
			assetCode: 'GD-011',
			category: 'Garden',
			dailyRateCents: 3400,
			availableUnits: 2,
			totalUnits: 4
		},
		{
			id: '62c75d28-4419-4350-b7eb-f84fc125905c',
			name: '3.5kVA Portable Generator',
			description:
				'Framed petrol generator for tools and temporary site power, with overload protection and two outlets.',
			photoID: '98be93df-cd92-42b9-a89d-8d607a87d5da',
			imageUrl: '/images/products/Portable_generator_with_control_…_20261007221651.jpg',
			assetCode: 'PW-003',
			category: 'Site equipment',
			dailyRateCents: 9800,
			availableUnits: 2,
			totalUnits: 3
		},
		{
			id: 'c96d2ab3-aa7b-4e78-8a04-a320c95726bc',
			name: '120L Concrete Mixer',
			description:
				'Portable electric mixer for concrete, mortar, and render, mounted on wheels for site movement.',
			photoID: '9f71f4ed-8ec2-40cf-8b92-ad510ce40e17',
			imageUrl: '/images/products/Portable_concrete_mixer_on_wheels_20261007221651.jpg',
			assetCode: 'CN-004',
			category: 'Site equipment',
			dailyRateCents: 7400,
			availableUnits: 1,
			totalUnits: 2
		},
		{
			id: '2d8dbfb3-fb20-43d7-a689-44590fb04a54',
			name: '6m Extension Ladder',
			description:
				'Industrial aluminium extension ladder with stabilising feet and rope-operated upper section.',
			photoID: '86d4e459-cfab-4a42-a786-d0ed2dc65ad9',
			imageUrl: '/images/products/Aluminium_extension_ladder_standing_20261007221651.jpg',
			assetCode: 'AC-016',
			category: 'Site equipment',
			dailyRateCents: 3900,
			availableUnits: 4,
			totalUnits: 5
		},
		{
			id: '88eb1e0c-e245-4483-86eb-b1bd38b15567',
			name: '1.8m Platform Ladder',
			description:
				'Trade-rated aluminium platform ladder with safety rail, tool tray, and non-slip feet.',
			photoID: 'b3a8ad93-f2f1-4709-bf62-d18407b6c6e9',
			imageUrl: '/images/products/Aluminium_platform_ladder_produc…_20261007221651.jpg',
			assetCode: 'AC-021',
			category: 'Site equipment',
			dailyRateCents: 3200,
			availableUnits: 3,
			totalUnits: 4
		},
		{
			id: 'a5d583f9-227f-49be-87a3-0a518857ae66',
			name: 'Mirrorless Camera Kit',
			description:
				'Hybrid photo and video kit with camera body, two lenses, batteries, charger, and padded carry bag.',
			photoID: 'da272112-d1ca-45a9-a819-a555365c822e',
			imageUrl: '/images/products/Rental_camera_kit_on_background_20261007221651.jpg',
			assetCode: 'AV-008',
			category: 'AV',
			dailyRateCents: 12500,
			availableUnits: 2,
			totalUnits: 3
		},
		{
			id: '095741ed-0860-40bd-ae70-01d00b0439b5',
			name: 'Fluid-Head Video Tripod',
			description:
				'Stable aluminium video tripod with fluid pan-and-tilt head, quick-release plate, and carry case.',
			photoID: '77089bd5-38e7-46ed-b6c7-85203004649f',
			imageUrl: '/images/products/Video_tripod_standing_in_studio_20261007221651.jpg',
			assetCode: 'AV-014',
			category: 'AV',
			dailyRateCents: 3600,
			availableUnits: 4,
			totalUnits: 4
		},
		{
			id: '2bcbb527-cdfa-4050-b1d7-334bd52faf0a',
			name: '4000-Lumen HD Projector',
			description:
				'Portable digital projector for presentations and events, supplied with remote, HDMI cable, and case.',
			photoID: '30d6168c-0ac6-4408-bd36-055642708d17',
			imageUrl: '/images/products/Compact_digital_projector_with_r…_20261007221651.jpg',
			assetCode: 'AV-019',
			category: 'AV',
			dailyRateCents: 8900,
			availableUnits: 2,
			totalUnits: 3
		},
		{
			id: 'ad3db23c-ab43-405e-8d43-a9e2428307cc',
			name: '12-inch Powered PA Speaker',
			description:
				'Portable powered speaker with stand and wireless microphone for speeches, classes, and small events.',
			photoID: 'fb8b2cd0-ecb2-4678-83c4-74cc4dbf1a57',
			imageUrl: '/images/products/PA_speaker_on_stand_20261007221651.jpg',
			assetCode: 'AV-025',
			category: 'AV',
			dailyRateCents: 7200,
			availableUnits: 3,
			totalUnits: 4
		},
		{
			id: '80314739-5cf1-4ab7-98d7-ab689e40efbc',
			name: 'Four-Person Dome Tent',
			description:
				'Weatherproof dome tent with full fly, sewn-in floor, pegs, poles, and compact carry bag.',
			photoID: 'fc6f7804-cc89-46f4-9c8f-1212b01ad3d4',
			imageUrl: '/images/products/Modern_camping_dome_tent_pitched_20261007221651.jpg',
			assetCode: 'OD-021',
			category: 'Outdoor',
			dailyRateCents: 4400,
			availableUnits: 4,
			totalUnits: 5
		},
		{
			id: '4658ac23-ae85-4df2-9fc3-8906904303ba',
			name: 'Two-Burner Camping Stove',
			description:
				'Compact two-burner stove with wind guards and carry case. Gas bottle supplied separately.',
			photoID: '97223708-81ab-489b-84d2-bef5aca2cb2c',
			imageUrl: '/images/products/Camping_stove_opened_for_use_20261007221651.jpg',
			assetCode: 'OD-028',
			category: 'Outdoor',
			dailyRateCents: 2200,
			availableUnits: 5,
			totalUnits: 6
		}
	];

	const categoryNames: ToolCategory[] = [
		'Tools',
		'Cleaning',
		'Garden',
		'Site equipment',
		'AV',
		'Outdoor'
	];

	type CategoryFilter = 'All equipment' | ToolCategory;
	type SortOption = 'name-asc' | 'rate-asc' | 'rate-desc' | 'stock-desc';

	let searchQuery = $state(page.url.searchParams.get('q') ?? '');
	let selectedCategory = $state<CategoryFilter>('All equipment');
	let sortOption = $state<SortOption>('name-asc');

	const requestedStart = page.url.searchParams.get('start') ?? '';
	const requestedEnd = page.url.searchParams.get('end') ?? '';
	const hasRequestedWindow =
		isValidDate(requestedStart) && isValidDate(requestedEnd) && requestedEnd > requestedStart;

	afterNavigate(() => {
		searchQuery = page.url.searchParams.get('q') ?? '';
	});

	const categoryCounts = $derived(
		categoryNames.map((name) => ({
			name,
			count: products.filter((product) => product.category === name).length
		}))
	);

	const filteredProducts = $derived.by(() => {
		const query = searchQuery.trim().toLowerCase();
		const matches = products.filter((product) => {
			const matchesCategory =
				selectedCategory === 'All equipment' || product.category === selectedCategory;
			const matchesQuery =
				query.length === 0 ||
				product.name.toLowerCase().includes(query) ||
				product.description.toLowerCase().includes(query) ||
				product.category.toLowerCase().includes(query) ||
				product.assetCode.toLowerCase().includes(query);

			return matchesCategory && matchesQuery;
		});

		return [...matches].sort((a, b) => {
			switch (sortOption) {
				case 'rate-asc':
					return a.dailyRateCents - b.dailyRateCents;
				case 'rate-desc':
					return b.dailyRateCents - a.dailyRateCents;
				case 'stock-desc':
					return b.availableUnits - a.availableUnits;
				default:
					return a.name.localeCompare(b.name);
			}
		});
	});

	function formatDate(value: string) {
		return new Intl.DateTimeFormat('en-AU', {
			day: 'numeric',
			month: 'short',
			year: 'numeric'
		}).format(new Date(`${value}T00:00:00`));
	}

	function isValidDate(value: string) {
		if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
		return !Number.isNaN(new Date(`${value}T00:00:00`).getTime());
	}

	function clearFilters() {
		searchQuery = '';
		selectedCategory = 'All equipment';
		sortOption = 'name-asc';
	}
</script>

<svelte:head>
	<title>Equipment Catalogue · Equipment Hire</title>
</svelte:head>

<section class="catalog-intro">
	<div class="container page-intro">
		<div>
			<h1>Equipment</h1>
			<p>Browse tools, cleaning equipment, site gear, outdoor equipment, and AV inventory.</p>
		</div>
		<p class="catalogue-summary"><strong>{products.length}</strong> products · Sydney depot</p>
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
			<p class="window-empty">No dates selected. Quantities below show current demo stock.</p>
			<a href="/home">Choose dates</a>
		{/if}
	</div>
</section>

<section class="container catalogue">
	<details class="mobile-categories">
		<summary>Categories <span>{selectedCategory}</span></summary>
		<div class="mobile-category-list">
			<button
				type="button"
				class:active={selectedCategory === 'All equipment'}
				aria-pressed={selectedCategory === 'All equipment'}
				onclick={() => (selectedCategory = 'All equipment')}
			>
				All equipment <span>{products.length}</span>
			</button>
			{#each categoryCounts as category (category.name)}
				<button
					type="button"
					class:active={selectedCategory === category.name}
					aria-pressed={selectedCategory === category.name}
					onclick={() => (selectedCategory = category.name)}
				>
					{category.name} <span>{category.count}</span>
				</button>
			{/each}
		</div>
	</details>

	<aside class="category-index" aria-label="Equipment categories">
		<h2>Categories</h2>
		<button
			type="button"
			class:active={selectedCategory === 'All equipment'}
			aria-pressed={selectedCategory === 'All equipment'}
			onclick={() => (selectedCategory = 'All equipment')}
		>
			<span>All equipment</span><strong>{products.length}</strong>
		</button>
		{#each categoryCounts as category (category.name)}
			<button
				type="button"
				class:active={selectedCategory === category.name}
				aria-pressed={selectedCategory === category.name}
				onclick={() => (selectedCategory = category.name)}
			>
				<span>{category.name}</span><strong>{category.count}</strong>
			</button>
		{/each}
		<p>Stock quantities are static demo data and are not yet checked against the selected dates.</p>
	</aside>

	<div class="results">
		<div class="catalogue-tools">
			<label class="search-field">
				<span>Search within equipment</span>
				<input
					type="search"
					placeholder="Name, category, or asset code"
					bind:value={searchQuery}
					aria-describedby="result-count"
				/>
			</label>

			<label class="sort-field">
				<span>Sort</span>
				<select bind:value={sortOption}>
					<option value="name-asc">Name A–Z</option>
					<option value="rate-asc">Daily rate: low to high</option>
					<option value="rate-desc">Daily rate: high to low</option>
					<option value="stock-desc">Most stock available</option>
				</select>
			</label>
		</div>

		<div class="results-heading">
			<p id="result-count" aria-live="polite">
				<strong>{filteredProducts.length}</strong>
				{filteredProducts.length === 1 ? 'product' : 'products'}
				{selectedCategory !== 'All equipment' ? `in ${selectedCategory}` : ''}
			</p>
			{#if searchQuery || selectedCategory !== 'All equipment' || sortOption !== 'name-asc'}
				<button type="button" onclick={clearFilters}>Clear filters</button>
			{/if}
		</div>

		{#if products.length === 0}
			<div class="empty-message">
				<p><strong>No equipment is currently listed</strong></p>
				<p>The catalogue has no customer-visible inventory.</p>
			</div>
		{:else if filteredProducts.length > 0}
			<div class="product-grid">
				{#each filteredProducts as product (product.id)}
					<ToolCard {product} />
				{/each}
			</div>
		{:else}
			<div class="empty-message">
				<p><strong>No equipment found</strong></p>
				<p>Try a different search or return to the full catalogue.</p>
				<button type="button" onclick={clearFilters}>Show all equipment</button>
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

	.page-intro h1 {
		margin: 0;
		color: var(--ink);
		font-size: clamp(2rem, 4vw, 2.35rem);
		font-weight: 720;
		letter-spacing: -0.035em;
		line-height: 1.1;
	}

	.page-intro > div > p {
		max-width: 42rem;
		margin: 0.55rem 0 0;
		color: var(--muted);
		font-size: 0.95rem;
	}

	.catalogue-summary {
		margin: 0;
		color: var(--muted);
		font-size: 0.8rem;
		white-space: nowrap;
	}

	.catalogue-summary strong {
		color: var(--ink);
		font-size: 1.15rem;
		font-variant-numeric: tabular-nums;
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
		font-family: ui-monospace, monospace;
		font-size: 0.75rem;
	}

	.window-title p {
		display: grid;
		gap: 0.1rem;
		margin: 0;
	}

	.window-title small,
	.window-empty,
	.window-layout dt {
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

	.window-layout dt,
	.window-layout dd {
		margin: 0;
	}

	.window-layout dd {
		margin-top: 0.15rem;
		font-size: 0.85rem;
		font-weight: 650;
		font-variant-numeric: tabular-nums;
	}

	.window-empty {
		flex: 1;
		margin: 0;
	}

	.window-layout > a {
		color: #fff;
		font-size: 0.8rem;
		font-weight: 650;
		text-decoration-color: var(--brand);
		text-underline-offset: 0.2rem;
		white-space: nowrap;
	}

	.catalogue {
		display: grid;
		grid-template-columns: 13rem minmax(0, 1fr);
		gap: clamp(2rem, 4vw, 3.5rem);
		padding-block: 2rem 4rem;
	}

	.category-index {
		align-self: start;
		position: sticky;
		top: 7.25rem;
	}

	.category-index h2 {
		margin: 0 0 0.7rem;
		color: var(--ink);
		font-size: 0.82rem;
	}

	.category-index button,
	.mobile-category-list button {
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
	.mobile-category-list button:hover,
	.mobile-category-list button.active {
		background: var(--surface);
		box-shadow: inset 3px 0 0 var(--brand);
		color: var(--ink);
	}

	.category-index button strong,
	.mobile-category-list button span {
		color: var(--muted);
		font-size: 0.75rem;
		font-variant-numeric: tabular-nums;
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

	.search-field,
	.sort-field {
		display: grid;
		gap: 0.4rem;
		color: var(--ink);
		font-size: 0.76rem;
		font-weight: 650;
	}

	.search-field input,
	.sort-field select {
		height: var(--control-height);
		padding: 0 0.8rem;
		border: 1px solid var(--line-dark);
		background: #fff;
		color: var(--ink);
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

	.results-heading p strong {
		margin-right: 0.15rem;
		color: var(--ink);
		font-size: 1rem;
		font-variant-numeric: tabular-nums;
	}

	.results-heading button,
	.empty-message button {
		padding: 0.35rem 0;
		border: 0;
		background: transparent;
		color: var(--brand-dark);
		font-size: 0.78rem;
		font-weight: 680;
		text-decoration: underline;
		text-underline-offset: 0.2rem;
		cursor: pointer;
	}

	.product-grid {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		column-gap: clamp(1rem, 2.5vw, 2rem);
	}

	.empty-message {
		padding: 3rem 0;
		border-top: 1px solid var(--line-dark);
		color: var(--muted);
	}

	.empty-message p {
		margin: 0.25rem 0;
	}

	.empty-message strong {
		color: var(--ink);
		font-size: 1rem;
	}

	@media (max-width: 1100px) {
		.product-grid {
			grid-template-columns: repeat(2, minmax(0, 1fr));
		}
	}

	@media (max-width: 820px) {
		.window-layout {
			flex-wrap: wrap;
			gap: 0.75rem 1.5rem;
			padding-block: 0.85rem;
		}

		.window-title {
			width: 100%;
		}

		.window-layout dl {
			order: 3;
			width: 100%;
			flex-basis: 100%;
		}

		.window-layout dl div:first-child {
			border-left: 0;
			padding-left: 0;
		}

		.catalogue {
			display: block;
			padding-top: 1.25rem;
		}

		.category-index {
			display: none;
		}

		.mobile-categories {
			display: block;
			margin-bottom: 1rem;
			border-top: 1px solid var(--line-dark);
			border-bottom: 1px solid var(--line-dark);
		}

		.mobile-categories summary {
			display: flex;
			min-height: 3rem;
			align-items: center;
			justify-content: space-between;
			font-size: 0.82rem;
			font-weight: 680;
			cursor: pointer;
		}

		.mobile-categories summary span {
			color: var(--muted);
			font-weight: 500;
		}

		.mobile-category-list {
			display: grid;
			grid-template-columns: 1fr 1fr;
			padding-bottom: 0.75rem;
		}

		.page-intro {
			align-items: start;
			flex-direction: column;
			gap: 0.75rem;
		}
	}

	@media (max-width: 600px) {
		.catalogue-tools {
			grid-template-columns: 1fr;
		}

		.product-grid {
			grid-template-columns: 1fr;
		}

		.window-layout dl {
			grid-template-columns: 1fr 1fr;
		}

		.window-layout dl div {
			padding: 0.35rem 0.75rem;
		}

		.window-layout dl div:last-child {
			display: none;
		}

		.mobile-category-list {
			grid-template-columns: 1fr;
		}
	}
</style>
