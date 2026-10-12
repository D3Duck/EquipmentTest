import { writable } from 'svelte/store';

export type UserRole = 'customer' | 'employee' | 'store_admin' | 'system_admin';

export type AuthUser = {
	id: string;
	username: string;
	display_name: string;
	role: UserRole;
};

export type AuthSession = {
	user: AuthUser;
	expires_at: string;
};

type AuthState = {
	status: 'loading' | 'authenticated' | 'anonymous';
	user: AuthUser | null;
	expiresAt: string | null;
};

export const authState = writable<AuthState>({ status: 'loading', user: null, expiresAt: null });

let pendingLoad: Promise<void> | null = null;

export function loadSession(force = false): Promise<void> {
	if (!force && pendingLoad) return pendingLoad;
	pendingLoad = fetch('/api/session', {
		credentials: 'include',
		headers: { Accept: 'application/json' }
	})
		.then(async (response) => {
			if (response.ok) {
				applySession((await response.json()) as AuthSession);
				return;
			}
			authState.set({ status: 'anonymous', user: null, expiresAt: null });
		})
		.catch(() => {
			authState.set({ status: 'anonymous', user: null, expiresAt: null });
		})
		.finally(() => {
			pendingLoad = null;
		});
	return pendingLoad;
}

export function applySession(session: AuthSession) {
	authState.set({
		status: 'authenticated',
		user: session.user,
		expiresAt: session.expires_at
	});
}

export async function signOut() {
	const response = await fetch('/api/logout', { method: 'POST', credentials: 'include' });
	if (!response.ok) throw new Error('sign-out failed');
	authState.set({ status: 'anonymous', user: null, expiresAt: null });
}

export function rolesForPath(pathname: string): UserRole[] | null {
	if (pathname === '/bookings' || pathname.startsWith('/bookings/')) {
		return ['customer', 'system_admin'];
	}
	if (pathname === '/store' || pathname.startsWith('/store/')) {
		return ['employee', 'store_admin', 'system_admin'];
	}
	if (pathname === '/system' || pathname.startsWith('/system/')) {
		return ['system_admin'];
	}
	return null;
}

export function defaultPathForRole(role: UserRole) {
	if (role === 'system_admin') return '/system';
	if (role === 'employee' || role === 'store_admin') return '/store';
	return '/equipment';
}
