local k = vim.keymap.set

k('n', '<F5>', function() require('dap').continue() end)
k('n', '<Leader>do', function() require('dap').step_over() end)
k('n', '<Leader>dn', function() require('dap').step_into() end)
k('n', '<Leader>du', function() require('dap').step_out() end)
k('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
k('n', '<Leader>lp',
    function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
k('n', '<Leader>dr', function() require('dap').repl.open() end)
-- k('n', '<Leader>dl', function() require('dap').run_last() end)
