# nvim-config

This is my neovim configuration. I have tailored it to be very featureful (LSP, debugging, git integration, some additional text objects and motions, etc) but also bloat-free otherwise. Features:

- No package manager. Plugins are submodules.
- No DAP integration, instead I use [brk.nvim](https://codeberg.org/kafva/brk.nvim) which simply creates a file such as a `.gdbinit` with the breakpoints. This avoids having to install many plugins to reimplement all the features of debuggers (assembly view, watch window, memory view, etc).
- Gitsigns + diffview, so that lines which are changed in git are visible in the editor (gitsigns) and the actual diff is also visible (diffview), even the diff against main/master. Further git integration is not present, as interactively staging and unstaging hunks from the editor is the only interaction which is not easier done (or done at all) from the command line. At least, for me.
- Some plugins which are just for style, mostly for visual clarity:
  - `rainbow-delimiters.nvim`, so matching parentheses show a matching color.
  - `neoscroll.nvim`, (smooth scrolling) to help lessen how often jumping from place to place causes me to lose my sense of direction within the file or codebase.
  - `lsp_lines.nvim`, to show all diagnostics as virtual text / inlay hints
  - `indent_blankline.nvim` to show a line connected the currently selected indented block, matching colors with any braces colored by `rainbow-delimiters`
  - `base16-nvim` for some color schemes
  - `todo-comments` which just nicely highlights comments containing WARN, TODO, HACK.
  - `nvim-web-devicaons`, which are used by the mini.files file explorer.
- TODO: come up with more TODOs

## TODO

- [ ] probably steal the better text objects from <https://github.com/chrisgrieser/nvim-various-textobjs>
- [ ] figure out how to make completion windows no interfere with typing, maybe need to use a leader key to accept them or something. currently i sometimes want to press tab but get completion instead. also: make completion not have a delay, if one exists.
- [ ] remove nvim-dap submodules

## Keybinds / actions and navigation

The `{ n }` indicates the mode in which the binding is relevant. `n` is normal, `i` is insert mode, `x` is visual selection, and `o` is "operator pending" ie. in the middle of a command, typing a motion.

```txt
<Leader>: Spacebar

TODO: might be necessary to remove or change z here, as there are other motions such as zz zt zb etc. not sure how that works. Could also unbind those other motions as I don't use them
{ n }: z                Leap to anywhere in any currently visible window
{ x, o }: z             Leap to anywhere in the focused window
{ n }: <Leader>o        Portal backwards
{ n }: <Leader>i        Portal forwards
{ n }: <Leader>f        Open file explorer and renaming tool and editor popup, mini.files
{ n }: <Leader>g        Open a picker for files tracked by git, not including submodules
{ n }: <Leader>h        Open a picker for lines with LSP diagnostics reported
{ n }: <Leader>j        Open a picker show all buffers other than the currently active one, sorted by most recently used
{ n }: <Leader>m        Open a picker for matches to a search term for any files in the CWD which are not in hidden or ignored directories
{ n }: <Leader>k        Open a picker for all defined user commands

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

TODO: Completion popup navigation (TODO: evaluate these and whether completion as I have it currently really makes sense):

["<C-k>"]
["<C-j>"]
["<C-b>"]
["<C-f>"]
["<C-Space>"]
["<C-y>"]
["<C-e>"]

Diffview plugin keybinds:

{ n }: <Leader>v        Toggle git diffview, useful for observing git diff without leaving the editor, jumping between git hunks, and staging and unstaging induvidual hunks.
{ n }: <Leader>vo       Open git diffview
{ n }: <Leader>vc       Close git diffview
{ n }: <Leader>vh       Show file history for current file
{ n }: <Leader>vH       Show file history for entire repo
{ x }: <Leader>vh       Show file history for visually selected text
{ n }: <Leader>vl       Show file history for current line
{ n }: <Leader>vm       Diff current branch and changes against main/master brance
{ n }: <Leader>vb       Open a telescope picker for branches and diff the current branch against that
{ n }: <Leader>vC       Open a telescope picker for commits and show file history for that commit

Misc:

{ n }: <Leader>pa   Copy absolute path to current buffer to "+ register

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
```
