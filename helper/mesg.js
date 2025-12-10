/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { window } from 'vscode'

const {
	showInformationMessage: vsc_info,
	showErrorMessage: vsc_error,
	showWarningMessage: vsc_warn,
} = window

function capitalize(str)
{
	const first = str.charAt(0)
	const rest = str.slice(1)
	const out = first.toUpperCase() + rest

	return out
}

export function die(mesg)
{
	const ui_mesg = capitalize(mesg)

	vsc_error(ui_mesg)
	throw new Error(`fatal: ${mesg}`)
}

export function warn(mesg)
{
	mesg = capitalize(mesg)
	vsc_warn(mesg)
}

export function info(mesg)
{
	mesg = capitalize(mesg)
	vsc_info(mesg)
}
