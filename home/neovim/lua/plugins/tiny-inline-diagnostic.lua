require("tiny-inline-diagnostic").setup({
  options = {
    overwrite_events = { "LspAttach", "DiagnosticChanged" },
  },
})
