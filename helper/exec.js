/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { execFileSync as node_exec } from 'node:child_process'

import wspath from './wspath.js'

export function exec(file, ...args)
{
	args.shift()
	return node_exec(file, args, { cwd: wspath, encoding: 'utf8' })
}
