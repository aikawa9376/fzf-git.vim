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
        \ 'sink*': function('fzf_git#sink', {'func' : 'FzfGitFile'}),
        \ 'options': '--preview "git diff -w --color -U100000 ' . expand('%:p') . ' | sed ''1,5d''" ' .
        \ '--delimiter : --preview-window +{3} --expect=ctrl-a -m'
        \ }
  call fzf#run(fzf#wrap(opts))
endfunction

function! fzf_git#get_hunk_target(target)
  return  systemlist('git --no-pager diff -w --no-ext-diff -U0 ' . a:target . ' | sh ' . s:sh_dir .
        \ 'diff-lines.sh | sed ''/^\/dev/d''')
endfunction

function! fzf_git#sink(lines) dict
  if a:lines[0] == 'ctrl-a'
    for w in range(1, len(a:lines) - 1)
      let diff = fzf_git#hunk_diff(system('git diff --no-ext-diff --no-color -U0 ' . split(a:lines[w], ':')[0]), split(a:lines[1], ':')[1] )
      call system('echo "' . diff . '" > /tmp/fzf-git.patch')
      call s:stage('/tmp/fzf-git.patch')
    endfor
    call feedkeys(":" . self.func . "\<CR>")
    return
  endif

  execute "edit +" . split(a:lines[1], ':')[1] . " " . split(a:lines[1], ':')[0]
endfunction

function! s:stage(diff)
  " Apply patch to index.
  call system('git apply --cached --unidiff-zero < ' . a:diff)
  if v:shell_error
    echom 'patch does not apply'
  endif
endfunction

function! fzf_git#hunk_diff(full_diff, linenumber)
  let modified_diff = []
  let keep_line = 1
  let adj = 0
  let adj_end = 1
  for line in split(a:full_diff, '\n')
    let hunk_info = fzf_git#parse_hunk(line)
    if len(hunk_info) == 4  " start of new hunk
      let keep_line = fzf_git#cursor_in_hunk(a:linenumber, hunk_info)
      if keep_line == 0 && adj_end == 1
        echom hunk_info[1]
        echom hunk_info[3]
        let adj += hunk_info[1] - hunk_info[3]
      endif
      if keep_line == 1
        let adj_end = 0
      endif
    endif
    if keep_line
      call add(modified_diff, line)
    endif
  endfor
  let diff = join(modified_diff, "\n")."\n"
  return s:adjust_hunk_summary(diff, adj)
endfunction

function! fzf_git#parse_hunk(line) abort
  let matches = matchlist(a:line, '^@@ -\(\d\+\),\?\(\d*\) +\(\d\+\),\?\(\d*\) @@')
  if len(matches) > 0
    let from_line  = str2nr(matches[1])
    let from_count = (matches[2] == '') ? 1 : str2nr(matches[2])
    let to_line    = str2nr(matches[3])
    let to_count   = (matches[4] == '') ? 1 : str2nr(matches[4])
    return [from_line, from_count, to_line, to_count]
  else
    return []
  end
endfunction

function! fzf_git#cursor_in_hunk(line, hunk) abort
  let current_line = a:line
  if current_line == 1 && a:hunk[2] == 0
    return 1
  endif
  if current_line >= a:hunk[2] && current_line < a:hunk[2] + (a:hunk[3] == 0 ? 1 : a:hunk[3])
    return 1
  endif
  return 0
endfunction

function! s:adjust_hunk_summary(hunk_diff, adj) abort
  let diff = split(a:hunk_diff, '\n', 1)
  let diff[4] = substitute(diff[4], '+\zs\(\d\+\)', '\=submatch(1)+a:adj', '')
  return join(diff, "\n")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
