" Author: Carlos Ruiz-Henestrosa <ruizh.cj@gmail.com>
" License: VIM License
" Version: 2012W27
" Put this file in the VIM plugins directory i.e. /usr/share/vim/vim73/plugin
" Make sure the loading of filetype plugins is enabled in your vimrc.
" if has("autocmd")
"   filetype indent on
" endif

" Check if ptsc-header was already loaded, and exit if so.
if exists("g:loaded_ptsc_header")
	finish
endif
let g:loaded_ptsc_header = 1

filetype detect

let s:rules = {'tab-size': 'tabstop', 'indent-size': 'shiftwidth', 'line-length': 'textwidth', 'new-line': 'fileformat', 'use-tabs': 'noexpandtab'}
" tab-stops is NOT supported because vim can't use assymetric ones.
let s:tagexp = '\c@format\.\([A-Za-z\-]\+\)[ \t]*\([ \t0-9A-Za-z]\+\)'

function s:ReadLines()
	" Search for a PT/SC header in the first 60 lines or 3000 characters.
	let s:taglist = [ ]
	for line in getline(1, 60)
		if line2byte(line)-1 > 3000
			break
		endif
		
		" Parse options
		let s:matched = matchlist(line, s:tagexp)
		if len(s:matched) == 0
			continue
		endif
		let s:pair = {'variable': s:matched[1], 'value': s:matched[2]}
		let s:taglist = add(s:taglist, s:pair)
	endfor
	return s:taglist
endfunction

function PtScParse(list)
	for var in a:list
		let s:formatoption = var["variable"]
		let s:value = var["value"]
		if s:formatoption ==? "use-tabs"
			if s:value =~ "\v\c(true)|(yes)|(on)"
				set noexpandtab
			elseif s:value =~ "\v\c(false)|(no)|(off)"
				set expandtab
			endif
		elseif s:formatoption ==? "tab-stops"
			echo "ERROR: Vim doesn't support asymmetric tabstops"
		elseif s:formatoption ==? "new-line"
			if s:value ==? "lf"
				set fileformat = "unix"
			elseif s:value ==? "cr"
				set fileformat = "mac"
			elseif s:value ==? "crlf"
				set fileformat = "dos"
			else
				echo "ERROR: Unsupported new-line sequence"
			endif
		else
			execute 'setlocal' s:rules[s:formatoption] . '=' . s:value
		endif
	endfor
endfunction

function PtScHeaderParse()
	let s:taglist = s:ReadLines()
	call PtScParse(s:taglist)
endfunction

autocmd VimEnter * call PtScHeaderParse()
