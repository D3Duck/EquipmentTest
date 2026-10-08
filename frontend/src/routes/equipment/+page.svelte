<script lang="ts">
	import ToolCard from '#lib/components/ToolCard.svelte';
	import type { Tool } from '#lib/types.ts';

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
</script>

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
			<span><strong>20</strong> products</span>
			<span><strong>75</strong> tracked units</span>
			<span><strong>07:00</strong> first collection</span>
		</div>
	</div>
</section>

{#if products.length > 0}
	<section class="container product-grid">
		{#each products as product (product.id)}
			<ToolCard {product} />
		{/each}
	</section>
{/if}

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

	.product-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(min(100%, 17.5rem), 1fr));
		gap: 1rem;
		padding-bottom: 4.5rem;
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

		.product-grid {
			grid-template-columns: 1fr;
			padding-bottom: 3.25rem;
		}
	}
</style>
