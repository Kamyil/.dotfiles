local document = require("image/utils/document")

return document.create_document_integration({
  name = "obsidian",
  default_options = {
    clear_in_insert_mode = false,
    download_remote_images = true,
    only_render_image_at_cursor = true,
    only_render_image_at_cursor_mode = "popup",
    floating_windows = false,
    filetypes = { "markdown", "quarto" },
    resolve_image_path = function(document_path, image_path, fallback)
      local clean = image_path:gsub("[|#^].*$", "")
      clean = clean:gsub("^%s*(.-)%s*$", "%1")
      if clean == "" then return fallback(document_path, image_path) end
      if clean:sub(1, 1) == "/" or clean:sub(1, 7) == "http://" or clean:sub(1, 8) == "https://" then return clean end
      if clean:sub(1, 1) == "~" then return vim.fn.fnamemodify(clean, ":p") end

      local vault = vim.fn.expand("~/second-brain")
      local candidates = {
        fallback(document_path, clean),
        vault .. "/" .. clean,
        vault .. "/assets/" .. clean,
        vault .. "/attachments/" .. clean,
      }
      for _, candidate in ipairs(candidates) do
        if vim.fn.filereadable(candidate) == 1 then return candidate end
      end
      return fallback(document_path, clean)
    end,
  },
  query_buffer_images = function(buffer)
    local bufnr = buffer or vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local images = {}
    local in_fence = false

    for row, line in ipairs(lines) do
      if line:match('^%s*```') or line:match('^%s*~~~') then
        in_fence = not in_fence
      elseif not in_fence then
        local pos = 1
        while true do
          local start, finish = line:find('!%[%[.-%]%]', pos)
          if not start then break end
          local inner = line:sub(start + 3, finish - 2)
          table.insert(images, {
            node = nil,
            range = {
              start_row = row - 1,
              start_col = start - 1,
              end_row = row - 1,
              end_col = finish,
            },
            url = inner,
          })
          pos = finish + 1
        end
      end
    end

    return images
  end,
})
