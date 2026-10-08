<script lang="ts">
	import favicon from '#lib/assets/favicon.svg';
	import SiteFooter from '#lib/components/SiteFooter.svelte';
	import SiteHeader from '#lib/components/SiteHeader.svelte';
	import type { LayoutProps } from './$types';
	import '../app.css';

	let { children }: LayoutProps = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<div class="shell">
	<SiteHeader />
	<main class="site-main">
		{@render children()}
	</main>
	<SiteFooter />
</div>

<style>
	.shell {
		display: flex;
		min-height: 100vh;
		flex-direction: column;
	}

	.site-main {
		flex: 1;
	}
</style>
