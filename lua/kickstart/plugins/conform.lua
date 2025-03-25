return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      -- Remove the nested formatters_by_ft definition here
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
        tsx = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        scss = { 'prettier' },
        markdown = { 'prettier' },
        yaml = { 'prettier' },
        graphql = { 'prettier' },
        vue = { 'prettier' },
        angular = { 'prettier' },
        less = { 'prettier' },
        flow = { 'prettier' },
        sh = { 'beautysh' },
        bash = { 'beautysh' },
        zsh = { 'beautysh' },
        http = { 'kulala-fmt' },
        python = { 'black' },
      },
    },
    config = function(_, opts)
      local conform = require 'conform'
      conform.setup(opts)

      -- Customize prettier args
      require('conform.formatters.prettier').args = function(_, ctx)
        local prettier_roots = { '.prettierrc', '.prettierrc.json', 'prettier.config.js' }
        local args = { '--stdin-filepath', '$FILENAME' }
        local config_path = vim.fn.stdpath 'config'

        local localPrettierConfig = vim.fs.find(prettier_roots, {
          upward = true,
          path = ctx.dirname,
          type = 'file',
        })[1]
        local globalPrettierConfig = vim.fs.find(prettier_roots, {
          path = type(config_path) == 'string' and config_path or config_path[1],
          type = 'file',
        })[1]
        local disableGlobalPrettierConfig = os.getenv 'DISABLE_GLOBAL_PRETTIER_CONFIG'

        -- Project config takes precedence over global config
        if localPrettierConfig then
          vim.list_extend(args, { '--config', localPrettierConfig })
        elseif globalPrettierConfig and not disableGlobalPrettierConfig then
          vim.list_extend(args, { '--config', globalPrettierConfig })
        end

        local hasTailwindPrettierPlugin = vim.fs.find('node_modules/prettier-plugin-tailwindcss', {
          upward = true,
          path = ctx.dirname,
          type = 'directory',
        })[1]

        if hasTailwindPrettierPlugin then
          vim.list_extend(args, { '--plugin', 'prettier-plugin-tailwindcss' })
        end

        return args
      end

      conform.formatters.beautysh = {
        prepend_args = function()
          return { '--indent-size', '2', '--force-function-style', 'fnpar' }
        end,
      }
    end,
  },
}
