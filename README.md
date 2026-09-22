# nvim-config

This is my neovim configuration. I have tailored it to be very featureful (LSP, debugging, git integration, some additional text objects and motions, etc) but not too bloated otherwise. Here are the overall features

- Instead of using a package manager, I have cloned the plugins directly into `pack/plugins/start`. This is fine for me as I find plugins tend to change their APIs too often, and so I like to pin their versions as well as the neovim version so I do not have to constantly think about maintaining this config.
- No DAP integration, instead I use [brk.nvim](https://codeberg.org/kafva/brk.nvim) which simply creates a file such as a `.gdbinit` describing the breakpoints placed in the editor. This avoids having to install many plugins to reimplement all the features of debuggers (assembly view, watch window, memory view, etc).
- Completion does not use tab or shift+tab, nor does it have a delay when typing. I find this to be a bit of a relic from other GUI editors which requires me to stop and wait to see completion, as well as often causing me to get a completion when I meant to type a tab, or sometimes vice versa.
- Gitsigns + diffview, so that lines which are changed in git are visible in the editor (gitsigns) and the actual diff is also visible (diffview), even the diff against main/master. Further git integration is not present, as interactively staging and unstaging hunks from the editor is the only interaction which is not easier done (or done at all) from the command line. At least, for me.
- Some plugins which are just for style, mostly for visual clarity:
  - `rainbow-delimiters.nvim`, so matching parentheses show a matching color.
  - `indent_blankline.nvim` to show a line connected the currently selected indented block, matching colors with any braces colored by `rainbow-delimiters`
  - `neoscroll.nvim`, (smooth scrolling) to help lessen how often jumping from place to place causes me to lose my sense of direction within the file or codebase.
  - `lsp_lines.nvim`, to show all diagnostics as virtual text / inlay hints
  - `base16-nvim` for some color schemes
  - `todo-comments` which just nicely highlights comments containing WARN, TODO, HACK.
  - `nvim-web-devicons`, which are used by the mini.files file explorer.

## List of lies told to me by Big Plugin, which I have become wise to since making this config

- You need a plugin manager (afaict these are glorified bash scripts to clone repos)
- You need lazy loading (actually, I want everything except LSP and treesitter to be on in every file anyways, so they should all be loaded at startup. Also, if your neovim lags while loading due to all your plugins, you have already screwed up. Plugin loading shouldn't need to be asynchronous unless the plugin's loading time is a function of buffer length or project size)
- You can emulate VSCode with just a few neovim plugins! (You don't want to do this)
  - A good example is mapping Tab and Shift+Tab to completion, which doesn't make sense because those are also keys you use to type normally
  - Also, bufferline/a tab bar doesn't make sense. I have three possible things I want to do with buffers, which bufferline only sometimes provides when there are only a few buffers open:
    - Use a picker / search through buffers
    - Go back to the previously visited buffer, or return after doing so
    - Use a hotkey bound to a specific buffer, such as `<Leader>1`, `<Leader>2`, etc.
  - DAP integration is a necessary feature (no, there are great debuggers out there and debugger interfaces, there is no need to recreate them in neovim).
- A dashboard is a cool feature (it just feels annoying, I usually start neovim and immediately open the file picker to open some files, because I know what I need to do)

## Plugins installed by lines of lua code (for both implementation and tests)

I keep this list just to be aware of how much stuff has accumulated in the dependencies of this config, and to judge whether the size of a plugin is really worth the features that I actually use. "not including tests" excludes `test/`, `tests/`, `spec/`, `testdata/`, `fixtures/`. Collected with `nix shell nixpkgs#cloc -c cloc --include-lang=Lua <plugin dir>`

```txt
rainbow-delimiters.nvim         53,476 lines (but  1,547 when not including tests)
none-ls.nvim                    20,825 lines (but 13,646 when not including tests)
trailblazer.nvim                17,607 lines (but  2,817 when not including tests)
telescope.nvim                  16,393 lines (but 14,306 when not including tests)
nvim-colorizer.lua              15,201 lines (but  6,444 when not including tests)
plenary.nvim                    14,074 lines (but 10,382 when not including tests)
gitsigns.nvim                   11,489 lines (but  8,483 when not including tests)
deltaview.nvim                  10,965 lines (but  2,994 when not including tests)
nvim-cmp                         7,429 lines
nvim-treesitter                  6,929 lines (but  4,488 when not including tests)
precognition.nvim                5,903 lines (but  2,317 when not including tests)
nvim-surround                    3,605 lines (but  1,576 when not including tests)
indent-blankline.nvim            3,499 lines
base16-nvim                      3,192 lines
nvim-web-devicons                2,447 lines
leap.nvim                        2,294 lines
substitute.nvim                  1,814 lines (but    740 when not including tests)
nvim-treesitter-textobjects      1,708 lines (but  1,463 when not including tests)
mini.files                       1,513 lines
brk.nvim                         1,424 lines (but  1,037 when not including tests)
portal.nvim                      1,391 lines (but  1,104 when not including tests)
neoscroll.nvim                   1,248 lines (but    729 when not including tests)
mini.bracketed                     992 lines
todo-comments.nvim                 912 lines
mini.ai                            911 lines
nvim-spider                        751 lines
nvim-treesitter-textsubjects       488 lines
cmp-buffer                         381 lines
telescope-fzf-native.nvim          343 lines (but    244 when not including tests)
mini.pairs                         243 lines
mini.comment                       240 lines
lsp_lines.nvim                     235 lines
cmp-nvim-lsp                       228 lines
cmp-path                           196 lines
cmp-cmdline                        190 lines
mini.move                          181 lines
```

## TODO

- [ ] fix reenabling LSP causing old diagnostics to reappear but the LSP not seeming to restart/reattach
- [ ] unbind ctrl + hjkl in telescope popup in favor of jk navigating up and down while remaining in insert mode
- [ ] have a motion that means whole word and one that means subword. right now `iw` is one thing and `w` is another (word vs. subword), would be nice to have "inner subword" etc as motions
- [ ] set up dot-repeat for everything that it is relevant for, I think there are some where I have used lua functions but I shouldn't have
- [ ] fix semicolon and other text objects provided by nvim-treesitter-textsubjects. those seem to simply not work in some cases. I find only the ; to be reliable, and only in C/C++ code.
- [ ] deltaview opening a file from a picker, from :DeltaMenu, I get `deltaview.nvim/lua/deltaview/view.lua:292`: attempt to index a nil value
- [ ] add a text object for what is currently highlighted by indent_blankline. the semicolon text object from treesitter-text-subjects is pretty close, but only seems to work in C/C++ code.
- [ ] figure out weirdness where ctrl+jk in a mini.files moves the cursor to next/prev match, but when fuzzyfind is not happening it does up/down. maybe the former can be rebound to shift + jk in this mode?
- [ ] add keybinds like ctrl + d and ctrl + u, except they move the cursor only and not the view
- [ ] consider reverting (`<Leader>g`) back to just searching all non-hidden files
- [ ] consider using mini.icons instead of nvim-web-devicons
- [ ] finish packaging clangd with zig so it can be distributed statically for use on any linux system
- [ ] probably steal the better text objects from <https://github.com/chrisgrieser/nvim-various-textobjs>
- [ ] Figure out mini.files bookmarking
- [ ] improve or highlight the `[+]` statusbar indication that the current file needs saving. Assuming I don't get used to it, it would be nice for maybe the statusbar to appear a different color when the current buffer has unsaved changes, or something like that. Right now I tend to not notice when the current buffer needs to be saved.
- [ ] Sometimes, motions do not get processed when I would expect them to. I notice this most often when doing `ciw`. Nothing happens at all, but the second time I do it, it works fine. I suspect there is a stray keybind somewhere, maybe related to one of the navigations keys in normal mode. (Added :KeyLog usercommand to debug this, hopefully I can figure it out)

Performance improvements:

- [ ] fix mini.files briefly freezing whenever hovering a big file and showing a preview. ideally previews would be asynchronous. I think unfortunately the creator of mini.files really doesnt want to add tons of new features, debouncing or asynchronous behavior, so this probably requires forking mini.files...
- [ ] fix telescope lagging when loading the git files picker (I only notice this on my PC, haven't been able to reproduce it since...)

## Keybinds / actions and navigation

The `{ n }` indicates the mode in which the binding is relevant. `n` is normal, `i` is insert mode, `x` is visual selection, and `o` is "operator pending" ie. in the middle of a command, typing a motion.

```txt
<Leader>: Spacebar

{ n }: z                Leap to any visible location
{ n }: rr               Leap to (visit) any visible location, entering visual mode, then jumping back after changing modes. So replacing a letter with the normal r motion does not work.
{ x, o }: z             Leap to anywhere in the focused window
{ n }: <Leader>o        Portal backwards
{ n }: <Leader>i        Portal forwards
{ n }: <Leader>f        Open file explorer and renaming tool and editor popup, mini.files
{ n }: <Leader>g        Open a picker for files tracked by git, not including submodules
{ n }: <Leader>h        Open a picker for lines with LSP diagnostics reported
{ n }: <Leader>j        Open a picker show all buffers other than the currently active one, sorted by most recently used
{ n }: <Leader>m        Open a picker for matches to a search term for any files in the CWD which are not in hidden or ignored directories
{ n }: <Leader>k        Open a picker for all defined user commands
{ n }: <Leader>n        Open a picker for files with pending changes in git

Replace text (provided by substitute.nvim):

{ n }: <Leader>s        Follow this with two motions: one to select a range of text, and another to select something on each line of the selection from the first motion. Each line will have its selected item substituted by the contents of the main register. For example `<Leader>sip2w` will select the current paragraph (`ip`) and then the second word (`2w`) on each line.
{ x }: <Leader>s        Follow this with a motion and it will apply that motion to each line containing visually selected text, and replace the selected text on each line with the contents of the main register.
{ n }: <Leader>ss       TODO: what does this actually do... I need to test it

Move text:

{ n }: <Leader>a        Swap function parameter under cursor with the next parameter (treesitter-text-objects)
{ n }: <Leader>A        Swap function parameter under cursor with the previous parameter (treesitter-text-objects)
{ x }: Alt + {h,j,k,l}  Move visually selected text left/right/up/down by one unit

Trailblazer navigation:

{ n }: <Leader>tm       Place a trail mark at the cursor's location
{ n }: <Leader>tb       Teleport back to the previous trail mark and pop it off the stack
{ n }: <Leader>tj       Jump back by one mark without removing it from the stack
{ n }: <Leader>tk       Jump forward by one mark without removing it from the stack
{ n }: <Leader>tl       Toggle a window with a list of trail marks

Buffer management:

{ n }: Shift + x        Close the current buffer
{ n }: Shift + k        Move to the next buffer
{ n }: Shift + j        Move to the previous buffer

TODO: probably assign buffers to keybinds when opening similar to window manager workspaces, arbitrary order is a bit weird to get a sense of direction for. The buffer switcher popup can help with this a little by sorting chronologically.

Window management:

{ n }: Ctrl + {h,j,k,l} Resize currently focused window by 1 unit in any direction
{ n }: Alt + {h,j,k,l}  Jump to an adjacent window in any direction

Debugging:
(These keybinds only have the effect of generating a .gdbinit in the project directory, this config does not include DAP support).

{ n }: <Leader>b    Toggle breakpoint
{ n }: <Leader>dc   Toggle conditional breakpoint
{ n }: <Leader>ds   Toggle symbol breakpoint
{ n }: <Leader>dl   List all breakpoints
{ n }: <Leader>dC   Delete all breakpoints

Language server operations (pretty much neovim defaults):

{ n }: gd           Go to the definition of the symbol under the cursor
{ n }: gD           Go to the declaration of the symbol under the cursor
{ n }: gri          Go to implementation of symbol under cursor (the meaning of this seems to vary based on the LSP implementation).
{ n }: grr          Show references to symbol under cursor
{ n }: grt          Go to the definition of the type of the symbol under the cursor
{ n }: grn          Rename symbol under cursor
{ n, x }: gra       Show code actions
{ n }: g0           Show all LSP symbols in the current document
{ n, i }: Ctrl + S  Show signature help in a floating popup
{ n }: <Leader>u    Format the current buffer, if there is an attached language server that can do that

Completion

{ i }: <C-Space>    Ask for completions at the cursor
{ i }: <C-j>        Highlight the next entry
{ i }: <C-k>        Highlight the previous entry
{ i }: <C-y>        Accept the highlighted entry, or the top one if none is highlighted
{ i }: <C-e>        Dismiss the popup
{ i }: <C-b>        Scroll the documentation window up
{ i }: <C-f>        Scroll the documentation window down

Diffview plugin keybinds:

{ n }: <Leader>vv       Toggle git diff view, useful for observing git diff without leaving the editor. Shows the diff caused by the current staged and unstaged changes.
{ n }: <Leader>va       Show a diff view of all the currently changed files in one megabuffer
{ n }: <Leader>vm       Toggle git diff view against the main/master branch
{ n }: <Leader>vc       Open a picker with the last 50 commits on the current branch. Selecting one opens a quickfix review for it, like <Leader>vq
{ n }: <Leader>vq       Quickfix review for the current unstaged changes, use ]q / [q to step through changed files. Similar to <Leader>n
{ n }: <Leader>vf       Pick from commits that affect the current file and then show the relevant hunks from that commit
{ n }: <Leader>vl       Pick from commits affecting the current line (git log -L), then show any hunks from that commit affecting the current buffer. Unfortunately deltaview does not support limiting the diff to a line range
{ n }: <Leader>vH       Pick from all commits, then pick from a file, then show deltaview for the changes to that file for that commit

mini.files file explorer popup navigation (starts out in search mode initially, but its been a bit customized to be a fuzzy search):

{ n, i, x }: Ctrl + j   Move to the next entry, or to the next search match while searching
{ n, i, x }: Ctrl + k   Move to the previous entry, or to the previous search match while searching
{ n, i, x }: Ctrl + l   Go into the selected folder, otherwise open it if it's a file
{ n, i, x }: Ctrl + h   Go out of the current folder
{ n }: /                Start custom fuzzy search for the current directory
{ n }: <Esc>            Stop the search mode, same as for normal search in vim
{ n }: zh               Toggle showing hidden files
{ n }: <CR>             Go into the selected folder, otherwise open it if it's a file
{ n }: L                Go into the selected folder, otherwise open it if it's a file
{ n }: l                Go into the selected folder, if it is a folder
{ n }: h                Go out of the current folder
{ n }: =                Synchronize (make the actual filesystem reflect any edits made to the mini.files buffer)

Misc:

{ n }: <Leader>pa   Copy absolute path to current buffer to "+ register
{ n }: Ctrl + C     Temporarily show inline motion hints from precognition.nvim
{ n }: <Leader>pl   Toggle inline LSP diagnostics via lsp_lines.nvim
{ n }: <Leader>l    Toggle language servers for the current buffer and remove all diagnostics

```

## Commands

```txt
Provided by substitute.nvim

{ n }: s            Substitute text object with register
{ n }: ss           Substitute current line with register
{ x }: s            Substitute visually selected text with register
{ n }: sx           Exchange text object with the previous target of exchange if one exists, otherwise store text object as target
{ n }: sxx          Exchange current line with the previous target of exchange if one exists, otherwise store line as target
{ x }: X            Exchange visually selected text with the previous target of exchange if one exists, otherwise store visually selected text as the target
{ n }: sxc          Clear/reset current exchange target
{ n }: <Esc>        Clear/reset current exchange target

Provided by surround.nvim

{ n }: ys           Follow with a motion and then a character to surround the text selected by the motion with instances of the character (quotes, braces, etc).
{ n }: ds           Follow with a character to delete a surrounding pair of those characters
{ n }: cs           Follow with two characters to replace a surrounding pair of the first character with a pair of the second.

{ n }: gcc          Comment out the current line
{ n, x}: gc         Comment out either visual select or the text object (for example `gcip` to comment out the current paragraph)

```

## Motions

```txt
ae                          Entire current buffer

Provided by mini.ai (all support being prefixed by count, ie. 2i} to select within the second set of two nested brace sets):

{a,i}{\},\{,),(,[,],>,<}    Around (a) surrounding braces of a specific type, or inside (i) the braces.
{a,i}b                      Around or inside any type of bracket
{a,i}{",',`}                Around or inside a set of quotations of a particular type
{a,i}q                      Around or inside any type of quote
{a,i}?                      Around or inside an arbitrary pair of characters, the user will be prompted to type what they want
{a,i}t                      Around or inside a pair of HTML or XML style tags
{a,i}f                      Around or inside a function call. Inside means just the arguments, around means including the function name and call braces.
{a,i}a                      Around or inside a function call argument.
{a,i}n                      Around or inside next text object (TODO: how does this work?)
{a,i}l                      Around or inside last (previous) text object (TODO: how does this work?)

g[                          Go to next (TODO: what is this?)
g]                          Go to prev (TODO: what is this?)

Provided by mini.comment:

ic                          The hovered comment (for example there is `dic`, `vic`, and `cic` to delete, select, and change respectively)

TODO: Migrate objects provided by ae and treesittertext-objects to mini.ai custom text objects. This would consolidate things into one dependency, and mini.ai does not support changing the letters used for the builtin text objects afaict.

Provided by treesitter-text-subjects:

.                           Intelligently select the most relevant part of the syntax tree depending on the cursor position
;                           Select a syntactical container (class, function, etc.) depending on your location in the syntax tree.
i;                          Select the body of a syntactical container depending on your location in the syntax tree.

Provided by treesitter-text-objects:

{a,i}m                      Select around or inside current function (m for method)
{a,i}r                      Select around or inside current class (r just wasn't taken... maybe r for "record"?)

{],[}m                      Go to next or previous function, respectively.
{],[}r                      Go to next or previous struct/class, respectively.
{],[}a                      Go to next or previous function call parameter, respectively.

Provided by mini.bracketed (supports going to first/last with the capital letter is used):

{],[}i                      Go to next or previous indent
{],[}d                      Go to next or previous diagnostic
{],[}x                      Go to next or previous version control conflict
{],[}c                      Go to next or previous comment

Provided by nvim-spider (replacing builtin motions):

{ n, x, o }: w              Go to the start of the next subword (subword == word but treats capital letters and underscores as word separators)
{ n, x, o }: e              Go to the end of the next subword
{ n, x, o }: b              Go to the start of the previous subword
{ n, x, o }: ge             Go to the end of the previous subword

Provided by (and for) leap.nvim:

{],[}w                      Go to next or previous instance of the leaped-to pattern
at                          Around remote textobject, for example yatp{leap} will yank around a paragraph selected by a leap operation.
it                          Inside remote textobject, for example yitw{leap} will yank inside a word selected by a leap operation.

Custom, provided by gitsigns:

{],[}h                      Go to next or previous hunk in current buffer
```
