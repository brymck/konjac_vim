" =============================================================================
" File:        konjac.vim
" Description: Some stuff that helps with translation using konjac
" Maintainer:  Bryan McKelvey (bryan.mckelvey@gmail.com)
" Date:        January 29, 2012
" Version:     0.1
"
" License:
" Copyright (c) 2011 Bryan McKelvey
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the 'Software'), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
" =============================================================================

if exists("loaded_konjac")
  finish
endif
let loaded_konjac = 1

function! LookupInEijiro(visual)
  if a:visual
    let a_save = @a
    normal! gv"ay
    let match = '"' . @a . '"'
    let @a = a_save
  else
    let match = expand("<cword>")
  end

  tabnew ~/.konjac/eijiro.konjac

  " Clear selection
  normal! ggdG

  " URL encoding
  let match = substitute(match, '\s', '+', 'g')
  let match = substitute(match, '%', '%%', 'g')
  let match = substitute(match, '"', '%22', 'g')

  let result = system('curl -s "http://eow.alc.co.jp/' . match . '/UTF-8/?ref=sa" | grep -E "searchwordfont" -A 1 | sed -e "s/\(.*\)searchwordfont/> \1/g" -e "s/<[^>][^>]*>//g" -e "/^[\s-]*$/d"')
  let result_lines = split(result, "[\r\n]\\{1,2\\}")
  call append("$", result_lines)
  normal! ggdd

endfunction

function! SaveKonjac(from_lang, to_lang, visual, word, single, curpos)
  let original    = getline(1)[1:]
  let orig_esc    = substitute(substitute(original, '\', '\\\\', 'g'), '"', '\\"', 'g')
  let translation = getline(2)[1:]
  let trans_esc   = substitute(substitute(translation, '\', '\\\\', 'g'), '"', '\\"', 'g')

  " Leave if no translation has been provided
  if translation == ""
    echo "No translation provided, so no changes were made to dictionary."
    wq!
    return
  endif

  " Add translation to dictionary
  silent execute "normal! :!konjac add -f " . a:from_lang . " -t " . a:to_lang . " -o '" . orig_esc . "' -r '" . trans_esc . "'\<CR>"

  " Close current buffer
  wq!

  if a:single
    if a:visual
      " Go to and delete the last visual selection
      normal! gvx
    else
      " Set the previous cursor position and delete the inner word
      call setpos(".", a:curpos)
      normal! diw
    endif

    " Save the cursor position and contents of register a, paste the new word,
    " then restore the position and register contents
    let curpos = getpos(".")
    let a_save = @a
    let @a = translation
    normal! "aP
    let @a = a_save
    call setpos(".", curpos)
  else
    " Replace the entire document
    execute ':' . (a:word ? '%' : '') . 's/\V' . (&filetype == 'diff' ? '\^+\.\*\zs' : '') . original . '/' . translation . '/gc'

    " Return to previous position in document
    execute "normal! \<C-O>"
  endif
endfunction

function! OpenKonjac(from_lang, to_lang, visual, word, single)
  " Get cursor position
  let curpos = getpos(".")

  if a:visual
    " Save register a, yank visual selection into register a, store those in a
    " variable, restore register a
    let a_save = @a
    normal! gv"ay
    let match = @a
    let @a = a_save
  else
    let match = a:word ? expand("<cword>") : getline(".")
  endif

  " Get results from konjac
  let result = system("konjac suggest \"" . match . "\" -f " . a:from_lang . " -t " . a:to_lang)
  let result_lines = split(result, "[\r\n]\\{1,2\\}")
  let result_lines_len = len(result_lines)

  " Open split above text selection
  execute "above " . (result_lines_len + 2) . "sp ~/.konjac/vim_temp.diff"

  " Clear file
  normal! ggdG

  " Write results of konjac suggest
  call setline(1, "-" . match)
  call append("$", "+")
  call append("$", result_lines)
  normal! 2G
  if result_lines_len > 0
    call setline(2, substitute(result_lines[0], '^\d\+: \(.*\) (\d\+%)$', '+\1', ''))
    normal! l
  endif

  " Define arguments
  let args = '"' . a:from_lang . '","' . a:to_lang . '",' . a:visual . ',' . a:word . ',' . a:single . ',' . string(curpos)

  " Create buffer-specific remappings
  execute "nnoremap \<buffer> \<C-w> :call SaveKonjac(" . args . ")\<CR>"
  execute "inoremap \<buffer> \<C-w> \<Esc>:call SaveKonjac(" . args . ")\<CR>"
  execute "nnoremap \<buffer> \<C-q> :q<CR>"
  execute "inoremap \<buffer> \<C-q> \<Esc>:q<CR>"
endfunction
