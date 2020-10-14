" fzf_git.vim
" Version: 0.1.0
" Author : aikawa
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:sh_dir = expand('<sfile>:p:h:h').'/sh/'

function! fzf_git#project() abort
  let opts = {
        \ 'source': fzf_git#get_hunk_target(''),
        \ 'sink*': function('s:fzf_git#get_hunk_file'),
        \ 'options': ['--multi',
        \ '--ansi']
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! fzf_git#file() abort
  let opts = {
        \ 'source': fzf_git#get_hunk_target(expand('%:p')),
        \ 'sink*': function('s:fzf_git#get_hunk_file'),
        \ 'options': ['--multi',
        \ '--ansi']
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! fzf_git#get_hunk_target(target)
  return  systemlist('git --no-pager diff --no-ext-diff -U1000000 ' . a:target . ' | sh ' . s:sh_dir .
        \ 'diff-lines.sh | grep -E "^[^\"].*\:[0-9]+\:[\+|\-]" | sed ''/^\/dev/d''' .
        \ '| sed ''s/:[+-].*$//g'' | uniq')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
