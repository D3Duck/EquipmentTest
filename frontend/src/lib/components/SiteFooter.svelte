<script lang="ts">
	const currentYear = new Date().getFullYear();
</script>

<footer class="site-footer">
	<div class="container footer-shell">
		<div class="footer-copy">
			<strong>Built by Luuk Vlasblom</strong>
			<span>© {currentYear} · Svelte 5, Go, PostgreSQL and Docker</span>
		</div>
		<nav class="footer-links" aria-label="Footer navigation">
			<a href="/">Home</a>
			<a href="/equipment">Equipment</a>
			<a href="https://github.com/D3Duck/EquipmentTest" target="_blank" rel="noreferrer">GitHub</a>
		</nav>
	</div>
</footer>

<style>
	.site-footer {
		border-top: 2px solid var(--ink);
		background: #e6e3db;
	}

	.footer-shell {
		display: flex;
		min-height: 6.5rem;
		align-items: center;
		justify-content: space-between;
		gap: 2rem;
		color: var(--muted);
		font-size: 0.84rem;
	}

	.footer-copy {
		display: grid;
		gap: 0.25rem;
	}

	.footer-copy strong {
		color: var(--navy);
	}

	.footer-links {
		display: flex;
		align-items: center;
		gap: 1.25rem;
	}

	.footer-links a {
		font-weight: 650;
		text-decoration: none;
	}

	.footer-links a:hover {
		color: var(--brand-dark);
	}

	@media (max-width: 560px) {
		.footer-shell {
			align-items: flex-start;
			flex-direction: column;
			padding-block: 1.5rem;
		}

		.footer-links {
			flex-wrap: wrap;
		}
	}
</style>
