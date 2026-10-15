<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { applySession, defaultPathForRole, type AuthSession } from '#lib/auth.ts';

	let username = $state('');
	let password = $state('');
	let errorMessage = $state('');
	let isSubmitting = $state(false);
	const availableAccounts = [
		{ username: 'customer1', label: 'Customer' },
		{ username: 'customer2', label: 'Customer 2' },
		{ username: 'employee', label: 'Employee' },
		{ username: 'storeadmin', label: 'Store admin' },
		{ username: 'admin', label: 'System admin' }
	];

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

			const session = (await response.json()) as AuthSession;
			applySession(session);
			password = '';
			const requestedPath = page.url.searchParams.get('next');
			const destination = safeLocalPath(requestedPath)
				? requestedPath
				: defaultPathForRole(session.user.role);
			await goto(destination);
		} catch {
			errorMessage = 'The server could not be reached. Please try again.';
		} finally {
			isSubmitting = false;
		}
	}

	function useAvailableAccount(selectedUsername: string) {
		username = selectedUsername;
		password = 'password';
		errorMessage = '';
	}

	function safeLocalPath(value: string | null): value is string {
		return Boolean(value?.startsWith('/') && !value.startsWith('//'));
	}
</script>

<svelte:head>
	<title>Sign in · Equipment Hire</title>
	<meta name="description" content="Sign in to Equipment Hire." />
</svelte:head>

<section class="login-page">
	<div class="login-card">
		<div class="login-heading">
			<h1>Sign in</h1>
			<p>Manage your bookings and check collection details.</p>
		</div>

		<div class="login-content">
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

			<div class="account-access">
				<h2>Available accounts</h2>
				<p>Every account uses the fictional password <code>password</code>.</p>
				<div class="account-grid">
					{#each availableAccounts as account (account.username)}
						<button type="button" onclick={() => useAvailableAccount(account.username)}>
							<strong>{account.label}</strong><span>{account.username}</span>
						</button>
					{/each}
				</div>
			</div>
		</div>

		<p class="login-note">These are shared accounts. Do not use a password from another service.</p>
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

	.account-access {
		margin-top: 1.5rem;
		padding-top: 1.25rem;
		border-top: 1px solid var(--line);
	}

	.account-access h2,
	.account-access p {
		margin: 0;
	}

	.account-access h2 {
		color: var(--ink);
		font-size: 0.95rem;
	}

	.account-access p {
		margin-top: 0.4rem;
		color: var(--muted);
		font-size: 0.78rem;
	}

	.account-access code {
		color: var(--ink);
	}

	.account-grid {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: 0.5rem;
		margin-top: 0.9rem;
	}

	.account-grid button {
		display: grid;
		min-height: 3.4rem;
		align-content: center;
		justify-items: start;
		margin: 0;
		padding: 0.55rem 0.7rem;
		border-color: var(--line-dark);
		background: var(--surface-alt);
		color: var(--ink);
		text-align: left;
	}

	.account-grid button:hover {
		border-color: var(--ink);
		background: var(--surface);
	}

	.account-grid button span {
		margin-top: 0.2rem;
		color: var(--muted);
		font:
			0.7rem ui-monospace,
			monospace;
	}

	.account-grid button:last-child {
		grid-column: 1 / -1;
	}

	@media (min-width: 48rem) {
		.login-card {
			width: min(100%, 52rem);
		}

		.login-content {
			display: grid;
			grid-template-columns: minmax(0, 1fr) minmax(17rem, 1fr);
			gap: 2rem;
			align-items: start;
		}

		.account-access {
			margin-top: 0;
			padding: 0 0 0 2rem;
			border-top: 0;
			border-left: 1px solid var(--line);
		}
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
