/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { workspace as vsc_workspace } from 'vscode'

const { workspaceFolders: vsc_wsf_list } = vsc_workspace

export function vsc_ws_prefix()
{
	const wsf = vsc_wsf_list[0]
	const uri = wsf.uri

	return uri.fsPath
}

export function vsc_map_ctx(ctx)
{
	return {
		environ: ctx.environmentVariableCollection,
		current: ctx.extension,

		binary: {
			mode: ctx.extensionMode,
			path: ctx.extensionPath,
			uri: ctx.extensionUri,
		},

		datadir: ctx.globalStoragePath,
		datadir_uri: ctx.globalStorageUri,

		ws_datadir: ctx.storagePath,
		ws_datadir_uri: ctx.storageUri,

		logdir: ctx.logPath,
		logdir_uri: ctx.logUri,

		secret: ctx.secrets,

		state: ctx.globalState,
		ws_state: ctx.workspaceState,

		lm_access: ctx.languageModelAccessInformation,
		cmds: ctx.subscriptions,
	}
}
