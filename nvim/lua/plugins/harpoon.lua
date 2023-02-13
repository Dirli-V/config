return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>m", function() require("harpoon.mark").add_file() end, desc = "Harpoon file" },
    { "<leader>h", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon toggle menu" },
    { "<leader>1", function() require("harpoon.ui").nav_file(1) end, desc = "Nav to file 1" },
    { "<leader>2", function() require("harpoon.ui").nav_file(2) end, desc = "Nav to file 2" },
    { "<leader>3", function() require("harpoon.ui").nav_file(3) end, desc = "Nav to file 3" },
    { "<leader>4", function() require("harpoon.ui").nav_file(4) end, desc = "Nav to file 4" },
    { "<leader>5", function() require("harpoon.ui").nav_file(5) end, desc = "Nav to file 5" },
  },
}
