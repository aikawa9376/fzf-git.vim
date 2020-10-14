" fzf_git.vim
" Version: 0.1.0
" Author : aikawa
" License: zlib License

if exists('g:loaded_fzf_git')
  finish
endif
let g:loaded_fzf_git = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:set(var, default)
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction

command! FzfGitFile call fzf_git#file()
" command! FzfGitProject call fzf_git#project()

let &cpo = s:save_cpo
unlet s:save_cpo
