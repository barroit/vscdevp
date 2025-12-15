/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { die, warn } from './mesg.js'
import { execlp, split_output } from './exec.js'

function assert_no_error(stderr)
{
	if (!stderr)
		return

	const giterr = split_output(stderr)

	die('failed to execute git', giterr[0])
}

function git_config_fetch(section, key)
{
	const path = `${section}.${key}`
	let { stdout, stderr } = execlp('git', 'git',
					'config', '--get', path, NULL)

	assert_no_error(stderr)

	if (!stdout) {
		warn(`no ${path} found with git-config(1)`)
		stdout = '????\n'
	}

	const lines = split_output(stdout)
	const out = lines[0]

	return out
}

export function git_user_name()
{
	return git_config_fetch('user', 'name')
}

export function git_user_email()
{
	return git_config_fetch('user', 'email')
}
