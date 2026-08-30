# neovim configuration TODO

- [ ] migrate to using https://github.com/the-argus/portable-nvim-config so that I don't worry about a plugin manager and basically vendor the plugins

Misc improvements:
- [ ] remove bufferline, comment-nvim, focus, neorg
- [ ] make alt keybinds work on macos with option? specifically for moving windows. might need to be bound to both left and right alt as well
- [ ] use [mini.ai](https://github.com/nvim-mini/mini.ai) to expand the inner/around text objects. the main addition i am interested in is `if` which is "inner function call"
- [ ] consider [mini.pairs](https://nvim-mini.org/mini.nvim/readmes/mini-pairs.html) which is just autopairs, opening quotes/braces will also add a closing one. I often find myself doing `<opening brace><closing brace><ESC><a>` to do this same thing.
- [ ] definitely get [mini.move](https://nvim-mini.org/mini.nvim/readmes/mini-move.html) or maybe [nvim-gomove](https://github.com/booperlv/nvim-gomove) to move the visually selected text. this is nice because I often want to tab the selected text multiple times and it is finicky.
- [ ] use [nvim-surround](https://github.com/kylechui/nvim-surround) which seems to have the same bindings as the excellent vim-surround
- [ ] use [precognition.nvim](https://github.com/tris203/precognition.nvim) which seems very useful for learning how to navigate within a line
- [ ] think about mini.pick vs. telescope vs. [fzf-lua](https://github.com/ibhagwan/fzf-lua). I am interested in being as portable as possible so I would imagine using fzf-native would be best, especially doing some tricks to compile fzf into my nvim binary. But I believe both telescope and fzf-lua support this.
- [ ] actually set up [nvim-dap](https://codeberg.org/mfussenegger/nvim-dap) properly, though I want k
- [ ] remove the damn FZF command so Format is always first. maybe there is a plugin which sorts most recently used usercmds first?
- [ ] maybe bind Format to a key, ideally the same key that vs and vscode do by default, if its not taken

Remove bufferline in favor of navigating buffers in a popup that only appears when navigating and is sorted by most recent. telescope of buffers is probably basically what I want. ideally it would be `<press and hold modifier to open menu><select buffer with some other keys><release modifier to go>`.
- [ ] use [trailblazer.nvim](https://github.com/LeonHeidelbach/trailblazer.nvim) for establishing jumps, though I need to read the docs
- [ ] use [portal.nvim](https://github.com/cbochs/portal.nvim) though once again i need to read the docs

Improve ability to overview project structure
- [ ] consider [arial.nvim](https://github.com/stevearc/aerial.nvim) for a nice outline window. outline.nvim also exists
- [ ] install a scrolling plugin such as [neoscroll](https://github.com/karb94/neoscroll.nvim)a
- [ ] remap scrolling keys Ctrl+y, Ctrl+e, Ctrl+u, Ctrl+d in favor of a modifier and J and K if possible
- [ ] use [mini.files](https://github.com/nvim-mini/mini.files) for viewing and editing file hierarchies, probably. unless nvim-tree is better at the viewing and navigating part? but make it open fullscreen on demand, I don't really need this popup or side panel thing. Maybe consider neo-tree as well, I saw this medium article about making it a floating file explorer toggle window https://medium.com/@oussamabaccara05/a-better-floating-file-explorer-in-neovim-with-neo-tree-018537e00ba3
- [ ] make sure mini.files, nvim-tree, or neo-tree all always show the root of the git repo if one exists above it

Get support for lsp rename symbol and undo rename symbol
- [ ] I think [nvim-lsp-file-operations](https://github.com/antosha417/nvim-lsp-file-operations) should work, though again I need to read the docs

Improve git workflow, specifically I would like to see my current changes as a hunk list, ideally with preview, and I want to be able to unstage hunks interactively
- [ ] probably just replace gitsigns with [diffview-plus.nvim](https://github.com/dlyongemallo/diffview-plus.nvim). look at [telescope integration](https://github.com/dlyongemallo/diffview-plus.nvim/blob/main/RECIPES.md)

Improve scrolling around in the visual area
- [ ] use [mini.bracketed](https://nvim-mini.org/mini.nvim/readmes/mini-bracketed.html) which can do "next/prev diagnostic" "next/prev version control marker" "next/prev quickfix"
- [ ] Get a plugin for just quickly scrolling up and down, basically doing pgup and pgdown, but without adding to the jumplist
- [ ] use a plugin like vimium for jumping around, there is [mini.jump2d](https://nvim-mini.org/mini.nvim/readmes/mini-jump2d.html) which seems a little shorter than [hop.nvim](https://github.com/smoka7/hop.nvim) but they are close. and [leap.nvim](https://git.disroot.org/andyg/leap.nvim) is the longest but also not by much, it seems people are not overcomplicating things :D. And there is [pounce.nvim](https://github.com/rlane/pounce.nvim) which is the most minimal of all, maybe my favorite... but it looks like it works differently than the others.

