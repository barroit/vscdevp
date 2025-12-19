/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { window } from 'vscode'

import { str_cap } from './string.js'

const {
	showInformationMessage: vsc_info,
	showErrorMessage: vsc_error,
	showWarningMessage: vsc_warn,
} = window

export function die(mesg, detail)
{
	const ui_mesg = capitalize(mesg)
	let option

	if (detail)
		option = { detail, modal: true }

	vsc_error(ui_mesg, option)
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
