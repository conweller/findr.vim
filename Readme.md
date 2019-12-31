# Findr.vim
An incremental file finder for neovim, inspired by [ivy](https://github.com/abo-abo/swiper) find-file
![Screenshot](screenshots/findr.gif)

## Requirements
* `nvim`: version > 0.4.0
* macos/linux

## Installation
Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'conweller/findr.vim'
```

## Usage
Launch with the command `:Findr`

Inside a findr buffer, filter subdirectories/files by entering in the desired
pattern

You can delimit multiple patterns you are searching for with a space.

The first matching file is selected by default, you can select a different
file using `<c-p>` (or `<up>` or  `<c-k>`) for the previous file, or `<c-n>`
(or `<down>` or  `<c-j>`) for the next file

Use `<cr>` to edit a file

Use `<tab>`, `/`, or `<c-l>` to change to the selected directory

Use `<c-h>` or use `<bs>` when the cursor is right of the prompt to got the
parent directory

Use `<m-p>` and `<m-n>` (or `<s-up>` and `<s-down>`) to go through your history
of recent files/directories

## Configuration
`g:findr_floating_window` Enable/disable floating window (default 1)
```vim
let g:findr_floating_window = 1
```

`g:findr_enable_border` Enable/disable border around floating window (default 1)
```vim
let g:findr_enable_border = 0
```

`g:findr_max_hist` Set maximum history file length (default 100)
```vim
let g:findr_max_hist = 100
```

`g:findr_border` Set characters for window border:

```vim
let g:findr_border = {
    \   'top':    ['┌', '─', '┐'],
    \   'middle': ['│', ' ', '│'],
    \   'bottom': ['└', '─', '┘'],
    \ }
```

For additional documentation see:
```vim
:h findr
```

## TODO
* `<c-w>` (delete word) functionality
* Additional commands (e.g. command for buffer narrowing)
* User defined sources
* Multicolumn support
