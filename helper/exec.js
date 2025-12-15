/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { spawnSync as node_spawn } from 'node:child_process'

import wspath from './wspath.js'

export function execlp(file, ...args)
{
	args.pop()

	const arg0 = args.shift()
	const config = {
		...this,
		argv0:    arg0,
		cwd:      wspath,
		encoding: 'utf8',
		shell:    true,
	}

	return node_spawn(file, args, config)
}

export function split_output(mesg)
{
	const arr = mesg.split('\n')

	arr.pop()
	return arr
}
