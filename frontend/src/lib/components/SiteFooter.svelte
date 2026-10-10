<script lang="ts">
	import GitHubIcon from './GitHubIcon.svelte';

	const currentYear = new Date().getFullYear();
</script>

<footer class="site-footer">
	<div class="container footer-shell">
		<div class="footer-brand">
			<span aria-hidden="true">E/H</span>
			<p><strong>Equipment Hire</strong><small>Sydney depot demo</small></p>
		</div>

		<nav class="footer-links" aria-label="Footer navigation">
			<a href="/home">Customer home</a>
			<a href="/equipment">Equipment</a>
			<a href="/cart">Cart</a>
			<a href="/bookings">My bookings</a>
			<a href="/store">Store operations</a>
			<a href="/system">System administration</a>
			<a href="/login">Sign in</a>
			<a href="/">Project overview</a>
		</nav>

		<div class="footer-copy">
			<strong>Built by Luuk Vlasblom</strong>
			<span>© {currentYear} · Svelte 5, Go, PostgreSQL and Docker</span>
			<a
				class="github-link"
				href="https://github.com/D3Duck/EquipmentTest"
				target="_blank"
				rel="noreferrer"><GitHubIcon /> <span>View source on GitHub</span></a
			>
		</div>
	</div>
</footer>

<style>
	.site-footer {
		border-top: 3px solid var(--brand);
		background: var(--ink);
		color: #d6dad7;
	}

	.footer-shell {
		display: grid;
		grid-template-columns: 1fr auto 1fr;
		align-items: start;
		gap: clamp(2rem, 6vw, 6rem);
		padding-block: 2.25rem;
		font-size: 0.8rem;
	}

	.footer-brand {
		display: flex;
		align-items: center;
		gap: 0.8rem;
	}

	.footer-brand > span {
		display: grid;
		width: 2.45rem;
		height: 2.45rem;
		place-items: center;
		border-left: 4px solid var(--brand);
		background: #fff;
		color: var(--ink);
		font-family: ui-monospace, monospace;
		font-size: 0.72rem;
		font-weight: 750;
	}

	.footer-brand p,
	.footer-copy {
		display: grid;
		gap: 0.2rem;
		margin: 0;
	}

	.footer-brand strong,
	.footer-copy strong {
		color: #fff;
	}

	.footer-brand small {
		color: #aeb5b0;
	}

	.footer-links {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.6rem 1.75rem;
	}

	.footer-links a,
	.footer-copy a {
		color: #d6dad7;
		text-decoration-color: #747c77;
		text-underline-offset: 0.2rem;
	}

	.footer-links a:hover,
	.footer-copy a:hover {
		color: #fff;
		text-decoration-color: var(--brand);
	}

	.footer-copy {
		justify-self: end;
		text-align: right;
	}

	.footer-copy > span {
		color: #aeb5b0;
	}

	.github-link {
		display: inline-flex;
		align-items: center;
		justify-self: end;
		gap: 0.35rem;
	}

	@media (max-width: 820px) {
		.footer-shell {
			grid-template-columns: 1fr 1fr;
		}

		.footer-copy {
			grid-column: 1 / -1;
			justify-self: start;
			padding-top: 1.25rem;
			border-top: 1px solid #3b413e;
			text-align: left;
		}

		.github-link {
			justify-self: start;
		}
	}

	@media (max-width: 540px) {
		.footer-shell {
			grid-template-columns: 1fr;
		}

		.footer-links {
			grid-template-columns: 1fr;
		}

		.footer-copy {
			grid-column: auto;
		}
	}
</style>
