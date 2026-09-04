local present, trailblazer = pcall(require, "trailblazer")
if not present then
    return
end

-- remapped Alt to <Leader>t to avoid conflicts with window resizing keybinds
trailblazer.setup({
    force_mappings = {
        nv = {
            motions = {
                -- place a new trail mark at the cursor
                new_trail_mark = "<Leader>tm",
                -- track back to the newest trail mark and pop it from the stack
                track_back = "<Leader>tb",
                -- peek move to one older mark
                peek_move_next_down = "<Leader>tj",
                -- peek move to one newer mark
                peek_move_previous_up = "<Leader>tk",
                -- toggle the trail mark list window
                toggle_trail_mark_list = "<Leader>tl",
            },
            actions = {
                delete_all_trail_marks = "<Leader>td",
            },
        },
    },
})
