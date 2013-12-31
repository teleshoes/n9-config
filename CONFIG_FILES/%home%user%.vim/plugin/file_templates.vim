" Search for a tag of the form:
" 
" With possible keys inside including the name (for simple things)
" or special keys like $BASENAME$ or $YEAR$.  Also allow the pattern
" to end with ';R' to use a replacement mode to maintain the field width
" Based originally on:
" http://lucumr.pocoo.org/cogitations/2007/08/03/vim-file-templates/

let s:TagMatch = '<+\(.\{-1,}\)\(;R\)\?+\+>'
let s:VarTagMatch = '<+\(\$[A-Z]\+\$\)\(;R\)\?+\+>'
let s:AskTagMatch = '#[A-Z_]\{-1,}#'
let s:searchSpecial = '$^*[]/\:'

let s:AskTagDefault = {}

command! -complete=customlist,ListAvailableTemplates -nargs=? 
			\ LoadFileTemplate call LoadFileTemplate("<args>")

command! -complete=customlist,ListAvailableTemplates -nargs=? 
			\ AddTemplate call AddTemplate("<args>")

let s:plugin_paths = split(globpath(&rtp, 'plugin/file_templates.vim'), '\n')
if len(s:plugin_paths) == 1
	let s:FileTemplatePath = fnamemodify(s:plugin_paths[0], ':p:h:h') . "/templates/"
elseif len(s:plugin_paths) == 0
	echoerr "Cannot find file_templates.vim"
else
	echoerr "Multiple plugin installs found: something has gone wrong!"
endif

function! ListAvailableTemplates(A,L,P)
	let s:bufferFileName = expand('%:t')
	let result = []
	let resultDict = {}
	if len(s:bufferFileName) > 0
		let extension = expand('%:e')
		let files = split(globpath(s:FileTemplatePath, '*.'.extension), '\n')

		for f in files
			let root = fnamemodify(f, ':t:r')
			let resultDict[root] = ''
		endfor
		let result = keys(resultDict)
	endif
	return result
endfunction

function! LoadFileTemplate(name)
	let s:bufferFileName = expand('%:t')
	if len(a:name) == 0
		if exists('g:file_template_default')
			if has_key(g:file_template_default, expand('%:e'))
				let template_name = g:file_template_default[expand('%:e')]
			elseif has_key(g:file_template_default, 'default')
				let template_name = g:file_template_default['default']
			else
				throw "No default template configured for this file"
			endif
		else
			throw "Invalid or Unspecified Template"
		endif
	else
		let template_name = a:name
	endif

	if len(s:bufferFileName) > 0
		execute "silent! 0r ".s:FileTemplatePath.tolower(template_name).".".expand('%:e')
		syn match vimTemplateMarker "<+.++>" containedin=ALL
		call ExpandTemplateNames()
		call AskForOtherNames()
	endif
endfunction

function! AddTemplate(name)
	let s:bufferFileName = expand('%:t')
	let template_name = a:name

	if len(s:bufferFileName) > 0
		execute "silent! r ".s:FileTemplatePath."templates/".tolower(template_name).".".expand('%:e')
		syn match vimTemplateMarker "<+.++>" containedin=ALL
		call ExpandTemplateNames()
		call AskForOtherNames()
	endif
endfunction


function! AskForOtherNames()
	let winstate = winsaveview()
	let old_query = getreg('/')
	let NameDict = {}
	normal gg
	let [lnum, cnum] = searchpos(s:TagMatch)
	while lnum != 0
		let matches = matchlist(getline(lnum), '^'.s:TagMatch, cnum-1)
		if len(matches) > 0
			" We have matches of tags, now search within those tags
			" for 'NAMES' (tags are in matches[1])
			let FullTag = matches[1]
			let NewTag = FullTag
			let askMatch = match(NewTag, s:AskTagMatch)
			while askMatch != -1
				" Check for the match in NameDict
				let askString = matchstr(NewTag, s:AskTagMatch)
				" Strip the #s
				let askString = askString[1:len(askString)-2]
				if index(keys(NameDict), askString) == -1
					" Look for a default value
					if index(keys(s:AskTagDefault), askString) == -1
						let defaultText = ""
					else
						let defaultText = s:AskTagDefault[askString]
					endif

					let newText = inputdialog('Details for tag ' . askString,
								\ defaultText,
								\ FullTag)

					" Only run if cancel wasn't pressed
					if newText != FullTag
						let s:AskTagDefault[askString] = newText
					else
						let newText = askString
					endif
					let NameDict[askString] = newText
				else
					let newText = NameDict[askString]
				endif

				" Now replace all instances of #askString# with newText
				let NewTag = substitute(NewTag, '#'.askString.'#', newText, "")

				let askMatch = match(NewTag, s:AskTagMatch)
			endwhile

			" Now update the text according to whether or not there was a ';R'
			if matches[2] == ";R"
				" We have to maintain the current width
				let width = len(matches[0])
				if len(NewTag) > width
					echoerr "Expanded variables are too long"
				else
					let fillVariable = NewTag
					let fillVariable .= repeat(' ', width-len(NewTag))
					execute lnum.'s:^.\{'.(cnum-1).'}\zs'.escape(matches[0], s:searchSpecial).':'.expand(fillVariable, s:searchSpecial).':'
				endif
			else
				" We don't have to maintain the width
				execute lnum.'s:^.\{'.(cnum-1).'}\zs'.escape(matches[0],s:searchSpecial).':'.expand(NewTag, s:searchSpecial).':'
			endif

		endif

		let [lnum, cnum] = searchpos(s:TagMatch)
	endwhile

	call setreg('/', old_query)
	call winrestview(winstate)
endfunction

function! ExpandTemplateNames()
	let winstate = winsaveview()
	let old_query = getreg('/')
	normal gg
	let variablesDict =
				\ {
				\     '$FILENAME$':   expand('%:t'),
				\     '$BASENAME$':   expand('%:t:r'),
				\     '$UBASENAME$':  toupper(expand('%:t:r')),
				\     '$LBASENAME$':  tolower(expand('%:t:r')),
				\     '$YEAR$':       strftime("%Y"),
				\     '$DATE$':       strftime('%d/%m/%Y'),
				\     '$DATETIME$':   strftime('%d/%m/%Y %H.%M.%S'),
				\     '$MCPREFIX$':   expand('%:t:r'),
				\     '$UCPREFIX$':   toupper(expand('%:t:r')),
				\ }

	let [lnum, cnum] = searchpos(s:VarTagMatch)
	while lnum != 0
		let matches = matchlist(getline(lnum), '^'.s:VarTagMatch, cnum-1)
		if len(matches) > 0
			" We have matches
			if index(keys(variablesDict), matches[1]) != -1
				let expandedVariable = variablesDict[matches[1]]
				if matches[2] == ";R"
					" We have to maintain the current width
					let width = len(matches[0])
					if len(expandedVariable) > width
						" The variable is too long!
						echoerr "Expanded Variable is Too Long"
					else
						let fillVariable = expandedVariable
						let fillVariable .= repeat(' ', width-len(expandedVariable))
						execute lnum.'s:^.\{'.(cnum-1).'}\zs'.escape(matches[0],s:searchSpecial).':'.escape(fillVariable, s:searchSpecial).':'
					endif
				else
					" We don't have to maintain the width
					execute lnum.'s:^.\{'.(cnum-1).'}\zs'.escape(matches[0],s:searchSpecial).':'.escape(expandedVariable, s:searchSpecial).':'
				endif
			else
				" Leave this one and let the user fill it in manually
			endif
		endif
		let [lnum, cnum] = searchpos(s:VarTagMatch)
	endwhile
	call setreg('/', old_query)
	call winrestview(winstate)
endfunction

command! TemplateJumpCmd echo ""

function! JumpToNextPlaceholder()
	" Save the old query
	let old_query = getreg('/')
	let [lnum, cnum] = searchpos(s:TagMatch)
	let matches = matchlist(getline(lnum), '^'.s:TagMatch, cnum-1)
	command! TemplateJumpCmd echo ""
	if len(matches) > 0
		" We have matches
		echomsg matches[1]
		if matches[2] == ";R"
			" Fixed width
			" Change the entire string to spaces
			execute lnum.'s:^.\{'.(cnum-1).'}\zs'.escape(matches[0],s:searchSpecial).':'.repeat(' ', len(matches[0])).':'
			exec "norm! ".(cnum)."|"
			command! TemplateJumpCmd startreplace
		else
			" Nice and simple
			exec "norm! ".(cnum)."|"
			if (len(matches[0])+cnum) >= len(getline(lnum))
				exec "norm! d$"
				command! TemplateJumpCmd startinsert!
			else
				exec "norm! d".len(matches[0])."l"
				command! TemplateJumpCmd startinsert
			endif
		endif
	endif
	call setreg('/', old_query)
endfunction

nnoremap <C-J> :call JumpToNextPlaceholder()<CR>:TemplateJumpCmd<CR>
inoremap <C-J> <ESC>:call JumpToNextPlaceholder()<CR>:TemplateJumpCmd<CR>
