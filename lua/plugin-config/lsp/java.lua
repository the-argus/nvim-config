local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" })
-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = '$HOME/.cache/jdtls/workspace/' .. project_name

local install_path = os.getenv("JDTLS_INSTALL_PATH")
local jar_folder = install_path .. '/share/java/jdtls/plugins/'
local jar_glob = jar_folder .. "org.eclipse.equinox.launcher_*.jar"
local launcher_files = vim.split(vim.fn.glob(jar_glob), '\n', { trimempty = true })
local launcher_file = nil

for _, file in pairs(launcher_files) do
    launcher_file = file
    break
end

if not launcher_file then
    print("Failed to find any files matching " .. jar_glob .. " unable to initialize jdtls")
    return
end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
		"-Dosgi.checkConfiguration=true",
        '-Dosgi.sharedConfiguration.area.readOnly=true',
		"-Dosgi.sharedConfiguration.area=" .. install_path .. '/share/java/jdtls/config_linux',
		-- "-Dosgi.configuration.cascaded=true",
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

        '-jar', launcher_file,

        '-data', workspace_dir,
    },

    root_dir,

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    -- settings = {
    --   java = {
    --   }
    -- },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    -- init_options = {
    --   bundles = {}
    -- },
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
