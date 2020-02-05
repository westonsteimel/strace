#!/bin/sh
#
# Define syntax testing primitives.
#
# Copyright (c) 2016 Dmitry V. Levin <ldv@altlinux.org>
# Copyright (c) 2016-2019 The strace developers.
# All rights reserved.
#
# SPDX-License-Identifier: GPL-2.0-or-later

. "${srcdir=.}/init.sh"

log_sfx()
{
	printf "%s" "$*" | tr -c '0-9A-Za-z-=,' '_' | head -c 128
}

log_path()
{
	printf "%s.%s" "$LOG" "$(log_sfx "$*")"
}

exp_path()
{
	printf "%s.%s" "$EXP" "$(log_sfx "$*")"
}

check_exit_status_and_stderr()
{
	$STRACE "$@" 2> "$(log_path "$*")" &&
		dump_log_and_fail_with \
			"strace $* failed to handle the error properly"
	match_diff "$(log_path "$*")" "$(exp_path "$*")" \
		"strace $* failed to print expected diagnostics"
}

check_exit_status_and_stderr_using_grep()
{
	$STRACE "$@" 2> "$(log_path "$*")" &&
		dump_log_and_fail_with \
			"strace $* failed to handle the error properly"
	match_grep "$(log_path "$*")" "$(exp_path "$*")" \
		"strace $* failed to print expected diagnostics"
}

check_e()
{
	local pattern="$1"; shift
	cat > "$(exp_path "$*")" << __EOF__
$STRACE_EXE: $pattern
__EOF__
	check_exit_status_and_stderr "$@"
}

check_e_using_grep()
{
	local pattern="$1"; shift
	cat > "$(exp_path "$*")" << __EOF__
$STRACE_EXE: $pattern
__EOF__
	check_exit_status_and_stderr_using_grep "$@"
}

check_h()
{
	local patterns="$1"; shift
	{
		local pattern
		printf '%s\n' "$patterns" |
			while read -r pattern; do
				printf '%s: %s\n' "$STRACE_EXE" "$pattern"
			done
		printf "Try '%s -h' for more information.\\n" "$STRACE_EXE"
	} > "$(exp_path "$*")"
	check_exit_status_and_stderr "$@"
}
