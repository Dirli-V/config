local libtee_lib_ok, libtee_lib = pcall(require, "litee.lib")
if not libtee_lib_ok then
  return
end

libtee_lib.setup({})

local calltree_ok, calltree = pcall(require, "litee-calltree")
if not calltree_ok then
  return
end

calltree.setup({})
