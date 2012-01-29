Konjac Vim plugin
=================

This is just a plugin to aid with integrating
[Konjac](https://github.com/brymck/konjac), a command-line tool I've written,
with [Vim](http://www.vim.org/). It adds the following functions:

```viml
" Translate a single word or phrase
OpenKonjac(from_lang, to_lang, 0, 1, 1)
OpenKonjac(from_lang, to_lang, 1, 1, 1)

" Translate a line
OpenKonjac(from_lang, to_lang, 0, 0, 1)

" Translate word or phrase for entire document
OpenKonjac(from_lang, to_lang, 0, 1, 0)
OpenKonjac(from_lang, to_lang, 1, 1, 0)

" Lookup in Eijiro
LookupInEijiro(0)
LookupInEijiro(1)
```

Installation
------------

### Pathogen

[Pathogen](http://www.vim.org/scripts/script.php?script_id=2332) is super-great
and highly recommended. This assumes the default setup, so adapt as needed (if
you're adventurous enough not to follow Mr. Pope's directions, you shouldn't
need mine ;) ):

```bash
cd ~/.vim
git submodule add git://github.com/brymck/konjac_vim.git bundle/konjac_vim
git submodule init
git submodule update
```

### Vanilla Vim

```bash
git clone git://github.com/brymck/konjac_vim.git
cp -r konjac_vim/* ~/.vim
```

Example
-------

```viml
" Translate a single word or phrase from Japanese to English
nnoremap <leader>e :call OpenKonjac("ja", "en", 0, 1, 1)
vnoremap <leader>e :call OpenKonjac("ja", "en", 1, 1, 1)
```
