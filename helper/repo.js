/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { join } from 'node:path'

import { execlp, split_output } from './exec.js'

export function prefix()
{
	const { stdout } = execlp('git', 'git',
				  'rev-parse', '--show-toplevel', NULL)
	const lines = split_output(stdout)

	return lines[0]
}

export function ls_files()
{
	const { stdout } = execlp('git', 'git', 'ls-files', '--cached',
				  '--others', '--exclude-standard', NULL)
	const repo = prefix()

	const basenames = split_output(stdout)
	const files = basenames.map(name => join(repo, name))

	return files
}
