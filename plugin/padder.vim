" FILENAME: padder.vim
" AUTHOR: Zachary Krepelka
" DATE: Tuesday, January 23rd, 2024
" ORIGIN: https://github.com/zachary-krepelka/vim-padder
" UPDATED: Saturday, January 27th, 2024 at 8:33 PM

" Variables {{{1

if exists('g:loaded_vim_padder')

	finish

endif

let g:loaded_vim_padder = 1

if !exists('g:padder_updates_visual')

	let g:padder_updates_visual = 1

endif

if !exists('g:padder_moves_cursor')

	let g:padder_moves_cursor = 1

endif

if !(exists('g:padder_clusivity') && g:padder_clusivity == 0)

	let g:padder_clusivity = 1

endif

let s:pad = ''
let s:direction = ''

" Commands {{{1

command! -range=% -bar Crunch
\
\	silent keeppatterns <line1>,<line2> s/\s\+$//e

command! -range=% -nargs=* Bang <line1>,<line2> call s:BigBang(<f-args>)

command! -range=% -nargs=* Bounce
\
\	<line1>,<line2> Crunch | <line1>,<line2> Bang <args>

" Functions {{{1

function! s:LongestLineLength(start, end)

	return max(map(getline(a:start, a:end), 'strdisplaywidth(v:val)'))

endfunction

function! s:BigBang(column = 0, pad = ' ', front = '', back = '') range

	let l:column = (a:column ? a:column :
	\
	\		s:LongestLineLength(a:firstline, a:lastline) + 1
	\
	\	) + g:padder_clusivity

	execute
	\
	\	"silent keeppatterns " ..
	\ 	a:firstline..','..a:lastline ..
	\
	\ 	"s/$/\\=" ..
	\	"a:front.." ..
	\	"repeat(a:pad[0], l:column-virtcol('$')).." ..
	\	"a:back/"

endfunction

function! s:Setup(direction, pad = ' ')

	let s:direction = a:direction
	let s:pad = a:pad

	set operatorfunc=s:Operator

	return 'g@'

endfunction

function! s:Operator(type = '') abort

	if a:type != 'line'

		return

	endif

	let l:save = winsaveview()

	'[,'] Crunch

	if s:direction " 1 -> Expansion, 0 -> Contraction

		'[,'] call s:BigBang(
		\
		\	v:none, s:pad, v:none,
		\
		\	v:count == 1 ? input('> ') : '')

	endif

	if g:padder_updates_visual

		execute "normal '[V']\<ESC>"

	endif

	if !g:padder_moves_cursor

		call winrestview(l:save)

	endif

endfunction

" Mappings {{{1

nnoremap <unique> <expr> z< <SID>Setup(0)
vnoremap <unique> <expr> z< <SID>Setup(0)
nnoremap <unique> <expr> z> <SID>Setup(1)
vnoremap <unique> <expr> z> <SID>Setup(1)

nnoremap <unique> <expr> z<< <SID>Setup(0) .. '_'
nnoremap <unique> <expr> z>> <SID>Setup(1, getcharstr())
vnoremap <unique> <expr> z>> <SID>Setup(1, getcharstr())

" Menus {{{1

if has("gui_running") && has("menu") && &go =~# 'm'

	amenu <silent> &Plugin.Padder.C&runch :Crunch<CR>
	amenu <silent> &Plugin.Padder.B&ang   :Bang<CR>
	amenu <silent> &Plugin.Padder.B&ounce :Bounce<CR>
	amenu <silent> &Plugin.Padder.H&elp   :tab help vim-padder<CR>

endif
