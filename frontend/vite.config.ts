import { sveltekit } from '@sveltejs/kit/vite';
import adapter from '@sveltejs/adapter-static';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, '..', '');
	const frontendPort = Number(env.VITE_FRONTEND_PORT || 5173);
	const backendHost = '127.0.0.1';
	const backendPort = env.GO_PORT || '8080';
	const backendTarget = `http://${backendHost}:${backendPort}`;

	return {
		plugins: [
			sveltekit({
				adapter: adapter({ fallback: 'index.html' })
			})
		],
		server: {
			port: frontendPort,
			proxy: {
				'/health': {
					target: backendTarget,
					changeOrigin: true
				},
				// For migrations
				'/database': {
					target: backendTarget,
					changeOrigin: true,
					secure: false
				},
				// TODO add images to new products
				'/images': {
					target: backendTarget,
					changeOrigin: true,
					secure: false
				},
				'/api': {
					target: backendTarget,
					changeOrigin: true,
					secure: false
				},
				'/ws': {
					target: backendTarget,
					changeOrigin: true,
					secure: false,
					ws: true // Enables WebSocket proxying
				}
			}
		}

		// Leave in when debugging builds - to see the files and line numbers on log entries and errors
		// 	build: {
		// 		sourcemap: true
		// },
	};
});
