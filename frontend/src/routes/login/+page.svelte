<script lang="ts">
	import { goto } from '$app/navigation';

	let username = $state('');
	let password = $state('');
	let errorMessage = $state('');
	let isSubmitting = $state(false);

	async function handleSubmit(event: SubmitEvent) {
		event.preventDefault();
		errorMessage = '';
		isSubmitting = true;

		try {
			const response = await fetch('/api/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				credentials: 'include',
				body: JSON.stringify({ username, password })
			});

			if (!response.ok) {
				const result = await response.json().catch(() => null);
				errorMessage =
					result?.error ?? 'Unable to sign in. Please check your details and try again.';
				return;
			}

			await goto('/equipment');
		} catch {
			errorMessage = 'The server could not be reached. Please try again.';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Sign in · Equipment Hire</title>
	<meta name="description" content="Sign in to the Equipment Hire demo." />
</svelte:head>

<section class="login-page">
	<div class="login-card">
		<div class="login-heading">
			<span class="login-icon" aria-hidden="true">
				<svg width="24" height="24" viewBox="0 0 24 24" fill="none">
					<path
						d="M7 10V8a5 5 0 0 1 10 0v2M5 10h14v11H5z"
						stroke="currentColor"
						stroke-width="1.8"
						stroke-linecap="round"
						stroke-linejoin="round"
					/>
				</svg>
			</span>
			<p class="eyebrow">Customer access / Depot 01</p>
			<h1>Sign in at the hire desk.</h1>
			<p>Review bookings, check collection details, and reserve equipment against live stock.</p>
		</div>

		<form onsubmit={handleSubmit}>
			<label for="username">
				Username
				<input
					id="username"
					name="username"
					type="text"
					autocomplete="username"
					placeholder="Enter your username"
					bind:value={username}
					required
				/>
			</label>

			<label for="password">
				Password
				<input
					id="password"
					name="password"
					type="password"
					autocomplete="current-password"
					placeholder="Enter your password"
					bind:value={password}
					required
				/>
			</label>

			{#if errorMessage}
				<p class="form-error" role="alert">{errorMessage}</p>
			{/if}

			<button type="submit" disabled={isSubmitting}>
				{isSubmitting ? 'Signing in…' : 'Sign in'}
				{#if !isSubmitting}
					<svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
						<path
							d="M5 12h14m-5-5 5 5-5 5"
							stroke="currentColor"
							stroke-width="2"
							stroke-linecap="round"
							stroke-linejoin="round"
						/>
					</svg>
				{/if}
			</button>
		</form>

		<p class="login-note">This is a portfolio demo. Do not use a password from another service.</p>
	</div>
</section>

<style>
	.login-page {
		display: grid;
		min-height: calc(100vh - 11rem);
		place-items: start center;
		padding: clamp(2.5rem, 5vw, 4rem) 1rem clamp(3rem, 6vw, 5rem);
	}

	.login-card {
		position: relative;
		width: min(100%, 31rem);
		padding: clamp(1.5rem, 5vw, 2.5rem);
		border: 2px solid var(--ink);
		border-radius: var(--radius-lg);
		background: var(--surface);
		box-shadow: var(--shadow);
	}

	.login-card::before {
		position: absolute;
		top: -2px;
		left: -2px;
		width: calc(100% + 4px);
		height: 0.45rem;
		background: var(--brand);
		content: '';
	}

	.login-heading {
		margin-bottom: 2rem;
		text-align: left;
	}

	.login-icon {
		display: grid;
		width: 3.25rem;
		height: 3.25rem;
		place-items: center;
		margin: 0 0 1.4rem;
		border: 1px solid var(--ink);
		border-radius: 1px;
		background: var(--brand);
		color: #fff;
	}

	.eyebrow {
		margin: 0 0 0.55rem;
		color: var(--brand-dark);
		font-size: 0.75rem;
		font-weight: 780;
		letter-spacing: 0.15em;
		text-transform: uppercase;
	}

	h1 {
		margin: 0;
		color: var(--navy);
		font-size: clamp(2rem, 7vw, 2.75rem);
		font-weight: 850;
		letter-spacing: -0.045em;
		line-height: 1;
	}

	.login-heading > p:last-child {
		margin: 0.9rem 0 0;
		color: var(--muted);
		font-size: 0.95rem;
		line-height: 1.6;
	}

	form {
		display: grid;
		gap: 1.2rem;
	}

	label {
		display: grid;
		gap: 0.5rem;
		color: var(--navy);
		font-size: 0.88rem;
		font-weight: 700;
	}

	input {
		width: 100%;
		height: 3.15rem;
		padding: 0 0.95rem;
		border: 1px solid var(--ink);
		border-radius: var(--radius-sm);
		outline: none;
		background: #f8f6ef;
		color: var(--ink);
		font-weight: 500;
		transition:
			border-color 150ms ease,
			box-shadow 150ms ease,
			background 150ms ease;
	}

	input::placeholder {
		color: #98a2b3;
	}

	input:focus {
		border-color: var(--brand);
		background: #fff;
		box-shadow: 0 0 0 3px var(--brand-soft);
	}

	.form-error {
		margin: -0.2rem 0 0;
		padding: 0.75rem 0.85rem;
		border: 1px solid #fecaca;
		border-radius: var(--radius-sm);
		background: #fef2f2;
		color: #b42318;
		font-size: 0.85rem;
		line-height: 1.45;
	}

	button {
		display: inline-flex;
		width: 100%;
		min-height: 3.2rem;
		align-items: center;
		justify-content: center;
		gap: 0.6rem;
		margin-top: 0.25rem;
		border: 2px solid var(--ink);
		border-radius: var(--radius-sm);
		background: var(--brand);
		color: #fff;
		box-shadow: 4px 4px 0 var(--ink);
		font-weight: 750;
		cursor: pointer;
		transition:
			transform 150ms ease,
			background 150ms ease,
			box-shadow 150ms ease;
	}

	button:hover:not(:disabled) {
		transform: translateY(-1px);
		background: var(--brand-dark);
		box-shadow: 2px 2px 0 var(--ink);
	}

	button:disabled {
		cursor: wait;
		opacity: 0.7;
	}

	.login-note {
		margin: 1.5rem 0 0;
		padding-top: 1.25rem;
		border-top: 1px solid var(--line);
		color: var(--muted);
		font-size: 0.78rem;
		line-height: 1.5;
		text-align: left;
	}

	@media (max-width: 480px) {
		.login-page {
			padding: 2rem 0.625rem 3rem;
		}

		.login-card {
			border-radius: var(--radius-md);
		}
	}

	@media (prefers-reduced-motion: reduce) {
		input,
		button {
			transition: none;
		}
	}
</style>
