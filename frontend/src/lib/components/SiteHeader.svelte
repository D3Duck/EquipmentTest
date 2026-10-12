<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { authState, signOut } from '#lib/auth.ts';
	import GitHubIcon from './GitHubIcon.svelte';

	let menuOpen = $state(false);
	let isSigningOut = $state(false);
	let signOutError = $state('');

	const navItems = $derived.by(() => {
		const items = [
			{ href: '/', label: 'Overview' },
			{ href: '/home', label: 'Home' },
			{ href: '/equipment', label: 'Equipment' }
		];
		const role = $authState.user?.role;
		if (role === 'customer' || role === 'system_admin') {
			items.push({ href: '/bookings', label: 'My bookings' });
		}
		if (role === 'employee' || role === 'store_admin' || role === 'system_admin') {
			items.push({ href: '/store', label: 'Store operations' });
		}
		if (role === 'system_admin') {
			items.push({ href: '/system', label: 'System' });
		}
		return items;
	});

	function isCurrent(href: string) {
		return page.url.pathname === href || page.url.pathname.startsWith(`${href}/`);
	}

	async function handleSignOut() {
		isSigningOut = true;
		signOutError = '';
		try {
			await signOut();
			menuOpen = false;
			await goto('/');
		} catch {
			signOutError = 'Sign-out failed. Please try again.';
		} finally {
			isSigningOut = false;
		}
	}

	function roleLabel(role: string) {
		return role.replaceAll('_', ' ');
	}
</script>

<header class="site-header">
	<div class="service-rail">
		<div class="container service-content">
			<nav aria-label="Project links">
				<a href="/">Portfolio overview</a>
				<a
					class="github-link"
					href="https://github.com/D3Duck/EquipmentTest"
					target="_blank"
					rel="noreferrer"><GitHubIcon /> <span>Source code</span></a
				>
			</nav>
			{#if signOutError}<p class="account-error" role="alert">{signOutError}</p>{/if}
		</div>
	</div>

	<div class="container nav-shell">
		<a class="brand" href="/home" aria-label="Equipment Hire customer home">
			<span class="brand-mark" aria-hidden="true">EH</span>
			<span class="brand-copy">Equipment Hire <small>Sydney depot</small></span>
		</a>

		<nav class="desktop-nav" aria-label="Store navigation">
			{#each navItems as item (item.href)}
				<a
					class="nav-link"
					href={item.href}
					aria-current={isCurrent(item.href) ? 'page' : undefined}
				>
					{item.label}
				</a>
			{/each}
		</nav>

		<form class="header-search" action="/equipment" method="get" role="search">
			<label class="visually-hidden" for="header-search">Search equipment</label>
			<svg width="17" height="17" viewBox="0 0 24 24" fill="none" aria-hidden="true">
				<circle cx="11" cy="11" r="6.5" stroke="currentColor" stroke-width="1.8" />
				<path d="m16 16 4 4" stroke="currentColor" stroke-width="1.8" />
			</svg>
			<input
				id="header-search"
				name="q"
				type="search"
				placeholder="Search equipment name or code"
				value={page.url.searchParams.get('q') ?? ''}
			/>
		</form>

		<a class="cart-link" href="/cart" aria-current={isCurrent('/cart') ? 'page' : undefined}>
			Cart
		</a>
		{#if $authState.user}
			<div class="account">
				<span class="account-copy">
					<strong>{$authState.user.display_name}</strong>
					<small>{roleLabel($authState.user.role)}</small>
				</span>
				<button type="button" class="sign-out" disabled={isSigningOut} onclick={handleSignOut}>
					{isSigningOut ? 'Signing out…' : 'Sign out'}
				</button>
			</div>
		{:else if $authState.status !== 'loading'}
			<a class="sign-in" href="/login">Sign in</a>
		{/if}

		<button
			class="menu-toggle"
			type="button"
			aria-label={menuOpen ? 'Close navigation' : 'Open navigation'}
			aria-expanded={menuOpen}
			aria-controls="mobile-navigation"
			onclick={() => (menuOpen = !menuOpen)}
		>
			{#if menuOpen}
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
					<path d="m6 6 12 12M18 6 6 18" stroke="currentColor" stroke-width="2" />
				</svg>
			{:else}
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true">
					<path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2" />
				</svg>
			{/if}
		</button>
	</div>

	<nav
		id="mobile-navigation"
		class="mobile-nav"
		data-open={menuOpen}
		aria-label="Mobile navigation"
	>
		<form action="/equipment" method="get" role="search">
			<label for="mobile-search">Search equipment</label>
			<div>
				<input id="mobile-search" name="q" type="search" placeholder="Drill, ladder, camera…" />
				<button type="submit">Search</button>
			</div>
		</form>
		{#each navItems as item (item.href)}
			<a
				class="nav-link"
				href={item.href}
				aria-current={isCurrent(item.href) ? 'page' : undefined}
				onclick={() => (menuOpen = false)}
			>
				{item.label}
			</a>
		{/each}
		<a class="nav-link" href="/cart" onclick={() => (menuOpen = false)}>Cart</a>
		{#if $authState.user}
			<p class="mobile-account">
				<strong>{$authState.user.display_name}</strong>
				<span>{roleLabel($authState.user.role)}</span>
			</p>
			<button class="mobile-sign-out" type="button" disabled={isSigningOut} onclick={handleSignOut}>
				{isSigningOut ? 'Signing out…' : 'Sign out'}
			</button>
		{:else if $authState.status !== 'loading'}
			<a class="nav-link" href="/login" onclick={() => (menuOpen = false)}>Sign in</a>
		{/if}
		<a class="nav-link secondary" href="/" onclick={() => (menuOpen = false)}>Portfolio overview</a>
		<a
			class="nav-link secondary github-link"
			href="https://github.com/D3Duck/EquipmentTest"
			target="_blank"
			rel="noreferrer"
			onclick={() => (menuOpen = false)}><GitHubIcon /> <span>Source code</span></a
		>
	</nav>
</header>

<style>
	.site-header {
		position: sticky;
		top: 0;
		z-index: 20;
		border-bottom: 1px solid var(--line-dark);
		background: rgba(252, 251, 247, 0.98);
	}

	.service-rail {
		border-bottom: 1px solid var(--line);
		background: var(--ink);
		color: #f4f3ef;
	}

	.service-content {
		display: flex;
		min-height: 2rem;
		align-items: center;
		justify-content: space-between;
		gap: 1rem;
		font-size: 0.74rem;
	}

	.service-content nav {
		display: flex;
		align-items: center;
		gap: 1.2rem;
		margin: 0;
	}

	.service-content a {
		color: #d9dcd9;
		text-decoration: none;
	}

	.github-link {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
	}

	.service-content a:hover {
		color: #fff;
		text-decoration: underline;
		text-underline-offset: 0.2rem;
	}

	.account-error {
		margin: 0 0 0 auto;
		color: #ffd4cc;
		font-size: 0.74rem;
	}

	.nav-shell {
		display: flex;
		min-height: 4.25rem;
		align-items: center;
		gap: clamp(1rem, 2.4vw, 2rem);
	}

	.brand {
		display: inline-flex;
		flex: 0 0 auto;
		align-items: center;
		gap: 0.75rem;
		color: var(--ink);
		font-weight: 760;
		letter-spacing: -0.02em;
		text-decoration: none;
	}

	.brand-mark {
		display: grid;
		width: 2.55rem;
		height: 2.55rem;
		place-items: center;
		border-left: 4px solid var(--brand);
		background: var(--ink);
		color: #fff;
		font-family: ui-monospace, monospace;
		font-size: 0.76rem;
		font-weight: 750;
		letter-spacing: -0.08em;
	}

	.brand-copy {
		display: grid;
		line-height: 1.05;
	}

	.brand-copy small {
		margin-top: 0.25rem;
		color: var(--muted);
		font-size: 0.68rem;
		font-weight: 500;
		letter-spacing: 0;
	}

	.desktop-nav {
		display: flex;
		align-self: stretch;
		align-items: center;
	}

	.nav-link {
		position: relative;
		display: inline-flex;
		height: 100%;
		align-items: center;
		padding: 0 0.7rem;
		color: var(--text);
		font-size: 0.88rem;
		font-weight: 650;
		text-decoration: none;
	}

	.nav-link:hover,
	.nav-link[aria-current='page'] {
		color: var(--ink);
	}

	.nav-link[aria-current='page']::after {
		position: absolute;
		right: 0.7rem;
		bottom: -1px;
		left: 0.7rem;
		height: 3px;
		background: var(--brand);
		content: '';
	}

	.header-search {
		position: relative;
		display: flex;
		width: min(28rem, 34vw);
		min-width: 13rem;
		align-items: center;
		margin-left: auto;
		border: 1px solid var(--line-dark);
		background: #fff;
	}

	.header-search svg {
		position: absolute;
		left: 0.8rem;
		color: var(--muted);
		pointer-events: none;
	}

	.header-search input {
		width: 100%;
		height: 2.7rem;
		padding: 0 0.8rem 0 2.35rem;
		border: 0;
		outline: 0;
		background: transparent;
		color: var(--ink);
		font-size: 0.86rem;
	}

	.header-search:focus-within {
		border-color: var(--brand);
		box-shadow: inset 3px 0 0 var(--brand);
	}

	.cart-link,
	.sign-in,
	.sign-out {
		display: inline-flex;
		min-height: 2.7rem;
		flex: 0 0 auto;
		align-items: center;
		padding: 0 0.9rem;
		border: 1px solid var(--line-dark);
		background: var(--surface);
		color: var(--ink);
		font-size: 0.86rem;
		font-weight: 650;
		text-decoration: none;
	}

	.account {
		display: flex;
		align-items: stretch;
	}

	.account-copy {
		display: grid;
		min-width: 8.5rem;
		align-content: center;
		padding: 0 0.8rem;
		border: 1px solid var(--line-dark);
		border-right: 0;
		background: var(--surface);
		line-height: 1.15;
	}

	.account-copy strong {
		font-size: 0.78rem;
	}

	.account-copy small {
		margin-top: 0.2rem;
		color: var(--muted);
		font-size: 0.66rem;
		text-transform: capitalize;
	}

	.sign-out {
		cursor: pointer;
	}

	.sign-out:disabled,
	.mobile-sign-out:disabled {
		cursor: wait;
		opacity: 0.65;
	}

	.cart-link:hover,
	.cart-link[aria-current='page'],
	.sign-in:hover,
	.sign-out:hover:not(:disabled) {
		border-color: var(--ink);
		background: var(--surface-alt);
	}

	.menu-toggle,
	.mobile-nav {
		display: none;
	}

	.menu-toggle {
		width: 2.8rem;
		height: 2.8rem;
		place-items: center;
		margin-left: auto;
		border: 1px solid var(--line-dark);
		background: var(--surface);
		color: var(--ink);
		cursor: pointer;
	}

	.visually-hidden {
		position: absolute;
		width: 1px;
		height: 1px;
		padding: 0;
		overflow: hidden;
		clip: rect(0, 0, 0, 0);
		white-space: nowrap;
		border: 0;
	}

	@media (max-width: 1180px) {
		.desktop-nav,
		.header-search,
		.cart-link,
		.sign-in,
		.account {
			display: none;
		}

		.menu-toggle {
			display: grid;
		}

		.mobile-nav[data-open='true'] {
			display: grid;
			padding: 1rem var(--page-gutter) 1.25rem;
			border-top: 1px solid var(--line);
			background: var(--surface);
		}

		.mobile-nav form {
			display: grid;
			gap: 0.45rem;
			margin-bottom: 0.75rem;
			padding-bottom: 1rem;
			border-bottom: 1px solid var(--line);
			font-size: 0.8rem;
			font-weight: 650;
		}

		.mobile-nav form div {
			display: grid;
			grid-template-columns: 1fr auto;
		}

		.mobile-nav input,
		.mobile-nav button {
			height: 2.8rem;
			border: 1px solid var(--line-dark);
		}

		.mobile-nav input {
			min-width: 0;
			padding: 0 0.8rem;
			border-right: 0;
			background: #fff;
		}

		.mobile-nav button {
			padding: 0 1rem;
			background: var(--ink);
			color: #fff;
			font-weight: 650;
		}

		.mobile-nav .nav-link {
			height: auto;
			min-height: 2.8rem;
			padding: 0.7rem 0.5rem;
			border-bottom: 1px solid var(--line);
		}

		.mobile-nav .nav-link[aria-current='page'] {
			box-shadow: inset 3px 0 0 var(--brand);
		}

		.mobile-nav .nav-link[aria-current='page']::after {
			display: none;
		}

		.mobile-nav .nav-link.secondary {
			color: var(--muted);
		}

		.mobile-account {
			display: flex;
			justify-content: space-between;
			gap: 1rem;
			margin: 0.75rem 0 0;
			padding: 0.75rem 0.5rem 0.35rem;
			color: var(--ink);
			font-size: 0.82rem;
		}

		.mobile-account span {
			color: var(--muted);
			text-transform: capitalize;
		}

		.mobile-sign-out {
			min-height: 2.8rem;
			border: 1px solid var(--line-dark);
			background: var(--surface-alt);
			color: var(--ink);
			font-weight: 700;
			cursor: pointer;
		}
	}

	@media (max-width: 600px) {
		.service-content nav {
			display: none;
		}

		.service-content {
			justify-content: center;
		}

		.nav-shell {
			min-height: 4rem;
		}

		.brand-mark {
			width: 2.35rem;
			height: 2.35rem;
		}
	}
</style>
