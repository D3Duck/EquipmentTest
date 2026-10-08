<script lang="ts">
	import { page } from '$app/state';

	let menuOpen = $state(false);

	const navItems = [
		{ href: '/', label: 'Home' },
		{ href: '/equipment', label: 'Equipment' }
	];

	function isCurrent(href: string) {
		return href === '/' ? page.url.pathname === href : page.url.pathname.startsWith(href);
	}
</script>

<header class="site-header">
	<div class="container nav-shell">
		<a class="brand" href="/" aria-label="Equipment Hire home">
			<span class="brand-mark" aria-hidden="true">
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none">
					<path
						d="M4 8.5h16v10H4zM8 8.5V6a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2.5M4 13h16"
						stroke="currentColor"
						stroke-width="1.8"
						stroke-linejoin="round"
					/>
				</svg>
			</span>
			<span class="brand-copy">Equipment Hire <small>Portfolio project</small></span>
		</a>

		<nav class="desktop-nav" aria-label="Primary navigation">
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

		<div class="nav-actions">
			<a
				class="source-link"
				href="https://github.com/D3Duck/EquipmentTest"
				target="_blank"
				rel="noreferrer"
			>
				<svg width="17" height="17" viewBox="0 0 24 24" fill="none" aria-hidden="true">
					<path
						d="M12 2.8a9.4 9.4 0 0 0-3 18.3c.5.1.7-.2.7-.5v-1.8c-2.8.6-3.4-1.2-3.4-1.2-.5-1.2-1.1-1.5-1.1-1.5-.9-.6.1-.6.1-.6 1 0 1.6 1 1.6 1 .9 1.6 2.4 1.1 2.9.9.1-.7.4-1.1.7-1.4-2.3-.3-4.7-1.1-4.7-5a3.9 3.9 0 0 1 1-2.7 3.6 3.6 0 0 1 .1-2.7s.9-.3 2.8 1a9.7 9.7 0 0 1 5.1 0c2-1.3 2.8-1 2.8-1a3.6 3.6 0 0 1 .1 2.7 3.9 3.9 0 0 1 1 2.7c0 3.9-2.4 4.7-4.7 5 .4.3.7.9.7 1.8v2.7c0 .3.2.6.7.5A9.4 9.4 0 0 0 12 2.8Z"
						fill="currentColor"
					/>
				</svg>
				Source
			</a>
			<span class="demo-account"><span class="account-avatar">D</span> Demo</span>
		</div>

		<button
			class="menu-toggle"
			type="button"
			aria-label="Toggle navigation"
			aria-expanded={menuOpen}
			aria-controls="mobile-navigation"
			onclick={() => (menuOpen = !menuOpen)}
		>
			{#if menuOpen}
				<svg width="21" height="21" viewBox="0 0 24 24" fill="none" aria-hidden="true">
					<path
						d="m6 6 12 12M18 6 6 18"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
					/>
				</svg>
			{:else}
				<svg width="21" height="21" viewBox="0 0 24 24" fill="none" aria-hidden="true">
					<path
						d="M4 7h16M4 12h16M4 17h16"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
					/>
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
		<a
			class="nav-link"
			href="https://github.com/D3Duck/EquipmentTest"
			target="_blank"
			rel="noreferrer">Source code</a
		>
	</nav>
</header>

<style>
	.site-header {
		position: sticky;
		top: 0;
		z-index: 20;
		border-bottom: 1px solid rgba(223, 228, 236, 0.88);
		background: rgba(255, 255, 255, 0.92);
		backdrop-filter: blur(16px);
	}

	.nav-shell {
		display: flex;
		min-height: 4.5rem;
		align-items: center;
		gap: 2rem;
	}

	.brand {
		display: inline-flex;
		align-items: center;
		gap: 0.7rem;
		color: var(--ink);
		font-weight: 760;
		letter-spacing: -0.02em;
		text-decoration: none;
	}

	.brand-mark {
		display: grid;
		width: 2.25rem;
		height: 2.25rem;
		place-items: center;
		border-radius: 0.7rem;
		color: #fff;
		background: linear-gradient(145deg, #0b9189, #075e69);
		box-shadow: 0 8px 20px rgba(8, 127, 121, 0.23);
	}

	.brand-copy {
		display: grid;
		line-height: 1.05;
	}

	.brand-copy small {
		margin-top: 0.2rem;
		color: var(--muted);
		font-size: 0.68rem;
		font-weight: 650;
		letter-spacing: 0.09em;
		text-transform: uppercase;
	}

	.desktop-nav {
		display: flex;
		align-self: stretch;
		align-items: center;
		gap: 0.25rem;
	}

	.nav-link {
		position: relative;
		display: inline-flex;
		height: 100%;
		align-items: center;
		padding: 0 0.85rem;
		color: #4f5d75;
		font-size: 0.93rem;
		font-weight: 620;
		text-decoration: none;
	}

	.nav-link:hover,
	.nav-link[aria-current='page'] {
		color: var(--brand-dark);
	}

	.nav-link[aria-current='page']::after {
		position: absolute;
		right: 0.85rem;
		bottom: -1px;
		left: 0.85rem;
		height: 2px;
		background: var(--brand);
		content: '';
	}

	.nav-actions {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin-left: auto;
	}

	.source-link,
	.demo-account {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		min-height: 2.6rem;
		border-radius: 999px;
		font-size: 0.88rem;
		font-weight: 650;
		text-decoration: none;
	}

	.source-link {
		padding: 0.5rem 0.8rem;
		color: #46546d;
	}

	.source-link:hover {
		background: var(--surface-alt);
		color: var(--navy);
	}

	.demo-account {
		padding: 0.35rem 0.8rem 0.35rem 0.35rem;
		border: 1px solid var(--line);
		background: var(--surface);
		color: var(--navy);
	}

	.account-avatar {
		display: grid;
		width: 1.9rem;
		height: 1.9rem;
		place-items: center;
		border-radius: 50%;
		background: var(--navy);
		color: #fff;
		font-size: 0.78rem;
	}

	.menu-toggle {
		display: none;
		width: 2.7rem;
		height: 2.7rem;
		place-items: center;
		border: 1px solid var(--line);
		border-radius: 0.75rem;
		background: var(--surface);
		color: var(--navy);
		cursor: pointer;
	}

	.mobile-nav {
		display: none;
	}

	@media (max-width: 860px) {
		.desktop-nav,
		.nav-actions {
			display: none;
		}

		.menu-toggle {
			display: grid;
			margin-left: auto;
		}

		.mobile-nav[data-open='true'] {
			display: grid;
			gap: 0.35rem;
			padding: 0 1rem 1rem;
			border-top: 1px solid var(--line);
			background: #fff;
		}

		.mobile-nav .nav-link {
			height: auto;
			padding: 0.85rem;
			border-radius: 0.65rem;
		}

		.mobile-nav .nav-link:hover,
		.mobile-nav .nav-link[aria-current='page'] {
			background: var(--brand-soft);
		}

		.mobile-nav .nav-link[aria-current='page']::after {
			display: none;
		}
	}

	@media (max-width: 560px) {
		.nav-shell {
			min-height: 4.15rem;
		}
	}
</style>
