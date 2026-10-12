<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { onMount } from 'svelte';
	import favicon from '#lib/assets/favicon.svg';
	import { authState, loadSession, rolesForPath } from '#lib/auth.ts';
	import SiteFooter from '#lib/components/SiteFooter.svelte';
	import SiteHeader from '#lib/components/SiteHeader.svelte';
	import type { LayoutProps } from './$types';
	import '../app.css';

	let { children }: LayoutProps = $props();

	onMount(() => {
		void loadSession();
	});

	$effect(() => {
		if ($authState.status === 'loading') return;
		const allowedRoles = rolesForPath(page.url.pathname);
		if (!allowedRoles) return;
		if (!$authState.user) {
			const destination = `${page.url.pathname}${page.url.search}`;
			void goto(`/login?next=${encodeURIComponent(destination)}`);
			return;
		}
		if (!allowedRoles.includes($authState.user.role)) {
			void goto('/access-denied');
		}
	});
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
