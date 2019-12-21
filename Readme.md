# Findr.vim
An incremental file finder for neovim, inspired by [ivy](https://github.com/abo-abo/swiper) find-file
![Screenshot](screenshots/findr.gif)

## Requirements
* `nvim`: version > 0.4.0
* macos/linux

## Usage
Launch with the command `:Findr`

Inside a findr buffer, filter subdirectories/files by entering in the desired
pattern

You can delimit multiple patterns you are searching for with a space.

The first matching file is selected by default, you can select a different
file using `<c-p>` for the previous file, or `<c-n>` for the next file

Use `<cr>` to edit a file

Use `<tab>` or `/` to change to the selected directory

## Configuration
Disable border around floating window
```vim
let g:findr_enable_border = 0
```

## TODO
* History
* Configuration
