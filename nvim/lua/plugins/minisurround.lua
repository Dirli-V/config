require("mini.surround").setup({
  mappings = {
    add = "<F3>",
    delete = "<F4>",
    find = "gzf",
    find_left = "gzF",
    highlight = "gzh",
    replace = "gzr",
    update_n_lines = "gzn",
  },
  custom_surroundings = {
    d = {
      input = { "dbg!%(().-()%)" },
      output = { left = "dbg!(", right = ")" },
    },
  },
})
