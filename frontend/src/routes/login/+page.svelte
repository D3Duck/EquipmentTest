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
			<h1>Sign in</h1>
			<p>Manage your bookings and check collection details.</p>
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
			</button>
		</form>

		<p class="login-note">This is a portfolio demo. Do not use a password from another service.</p>
	</div>
</section>

<style>
	.login-page {
		display: grid;
		min-height: calc(100vh - 17rem);
		place-items: start center;
		padding: clamp(3rem, 7vw, 6rem) 1rem;
		background: var(--canvas);
	}

	.login-card {
		position: relative;
		width: min(100%, 30rem);
		padding: clamp(1.5rem, 5vw, 2.25rem);
		border: 1px solid var(--line-dark);
		border-left: 5px solid var(--brand);
		background: var(--surface);
	}

	.login-heading {
		margin-bottom: 2rem;
		text-align: left;
	}

	h1 {
		margin: 0;
		color: var(--navy);
		font-size: clamp(1.9rem, 7vw, 2.2rem);
		font-weight: 720;
		letter-spacing: -0.035em;
		line-height: 1.1;
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
		border: 1px solid var(--line-dark);
		outline: none;
		background: #fff;
		color: var(--ink);
		font-weight: 500;
		transition:
			border-color 150ms ease,
			box-shadow 150ms ease,
			background 150ms ease;
	}

	input::placeholder {
		color: #737b76;
	}

	input:focus {
		border-color: var(--brand);
		background: #fff;
		box-shadow: 0 0 0 3px var(--brand-soft);
	}

	.form-error {
		margin: -0.2rem 0 0;
		padding: 0.75rem 0.85rem;
		border: 1px solid #d9a39d;
		background: #f8e9e7;
		color: var(--danger);
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
		border: 1px solid var(--brand-dark);
		background: var(--brand);
		color: #fff;
		font-weight: 750;
		cursor: pointer;
		transition: background 150ms ease;
	}

	button:hover:not(:disabled) {
		background: var(--brand-dark);
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
	}

	@media (prefers-reduced-motion: reduce) {
		input,
		button {
			transition: none;
		}
	}
</style>
