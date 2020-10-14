" fzf_git.vim
" Version: 0.1.0
" Author : aikawa 
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! fzf_git#file()
  call fzf#run({
  \  'source': s:mru_files_for_cwd('file'),
  \  'sink*': function('<SID>mru_file_sink'),
  \  'options': '-m -x --ansi
  \              --no-unicode --prompt=MRU:'.shellescape(pathshorten(getcwd())).'/
  \              --expect ctrl-t --header ":: Press C-t:toggle mru or mrw" --print-query',
  \  'down': '40%'})
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
