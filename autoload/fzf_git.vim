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
        \ 'sink*': function('fzf_git#sink'),
        \ 'options': '--preview "git diff -w --color -U100000 {1} | sed ''1,5d''" ' .
        \ '--delimiter : --preview-window +{3}'
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! fzf_git#file() abort
  let opts = {
        \ 'source': fzf_git#get_hunk_target(expand('%:p')),
        \ 'sink*': function('fzf_git#sink'),
        \ 'options': '--preview "git diff -w --color -U100000 ' . expand('%:p') . ' | sed ''1,5d''" ' .
        \ '--delimiter : --preview-window +{3}'
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! fzf_git#get_hunk_target(target)
  return  systemlist('git --no-pager diff -w --no-ext-diff -U0 ' . a:target . ' | sh ' . s:sh_dir .
        \ 'diff-lines.sh | sed ''/^\/dev/d''')
endfunction

function! fzf_git#sink(line)
  execute "edit +" . split(a:line[0], ':')[1] . " " . split(a:line[0], ':')[0]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
