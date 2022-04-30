-- pyright settings (mostly defaults)
return {
    settings = {
        pyright = {
            disableLanguageServices = false,
            disableOrganizeImports = false,
        },
        python = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace", -- "openFilesOnly" default
                -- unset: diagnosticSeverityOverrides
                extraPaths = {},
                logLevel = "Information",
                stubPath = "typings",
                typeCheckingMode = "basic",
                typeshedPaths = {},
                useLibraryCodeForTypes = true,
                pythonPath = "python",
                venvPath = ""
            }
        }
    }
}
