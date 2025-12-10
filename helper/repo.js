/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { join } from 'node:path'

import { exec } from './exec.js'

export function prefix()
{
	const output = exec('git', 'git', 'rev-parse', '--show-toplevel')
	const prefix = output.slice(0, -1)

	return prefix
}

export function ls_files()
{
	const output = exec('git', 'git', 'ls-files',
			    '--cached', '--others', '--exclude-standard')

	const prefix = prefix()
	let files = output.split('\n')

	files.pop()
	files = files.map(file => join(prefix, file))

	return files
}
