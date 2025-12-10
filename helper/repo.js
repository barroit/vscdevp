/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { join } from 'node:path'

import { execlp } from './exec.js'

export function prefix()
{
	const { stdout } = execlp('git', 'git',
				  'rev-parse', '--show-toplevel', NULL)
	const repo = stdout.slice(0, -1)

	return repo
}

export function ls_files()
{
	const { stdout } = execlp('git', 'git', 'ls-files', '--cached',
				  '--others', '--exclude-standard', NULL)
	let files = stdout.slice(0, -1)
	const repo = prefix()

	files = files.split('\n')
	files = files.map(file => join(repo, file))

	return files
}
