/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { workspace } from 'vscode'

const { workspaceFolders: ws_list } = workspace

const ws = ws_list[0]
const uri = ws.uri

export default uri.fsPath
