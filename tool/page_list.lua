local M = {}
-- --------------------------------------------------
-- page change

-- page_num: now page number
-- params: parameters number
-- LIMIT: view list limit
-- --------------------------------------------------
local function change_page(page_num, params, LIMIT)
	local max_page = math.ceil(params / LIMIT)
	local page_text = page_num .. "/" .. max_page
	gui.set_text(gui.get_node("page"), page_text)
	local pre_flag = true
	local next_flag = true
	if page_num == 1 then
		pre_flag = false
	end
	if page_num == max_page then
		next_flag = false
	end
	gui.set_enabled(gui.get_node("pre_button"), pre_flag)
	gui.set_enabled(gui.get_node("next_button"), next_flag)
	local begin_num = (page_num - 1) * LIMIT
	return begin_num
end
-- --------------------------------------------------
-- rewrite

-- num: rewrite target node number
-- var: content texts table
-- --------------------------------------------------
local function text_update(nodes, parent, target, var)
	for i=1, #nodes do
		local n = parent .. nodes[i]
		local node = target[n]
		local text = var[nodes[i]]
		gui.set_text(node, text)
	end
end
local function write(list, num, var)
	if var then
		local d = nil
		local target = list.boxs[num]
		text_update(list.nodes, list.parent, target, var)
		gui.set_enabled(target[list.template_head], true)
	end
end
local function hide(list, num)
	local target = list.boxs[num]
	gui.set_enabled(target[list.template_head], false)
end
-- --------------------------------------------------
-- init node clone and set position

-- ori_node: clone origin node
-- parent: parent node name
-- head: template head node name
-- limit: view list limit
-- --------------------------------------------------
function M.new(ori_node, parent, head, limit, pitch, params)
	local list = {}
	-- begin number of the page
	list.begin_num = 1
	-- parent node name
	list.parent = parent
	-- -- template head node name
	-- list.head = head
	-- templates node instans table
	list.boxs = {}
	--  node name table
	list.nodes = {}
	for key,var in pairs(params[1]) do
		table.insert(list.nodes, key)
	end
	-- view list limit
	list.limit = limit
	-- parent node name
	list.template_head = parent .. head
	local pos = gui.get_position(ori_node)
	for i = 1, limit do
		pos.y = pitch * (i - 1)
		local target = gui.clone_tree(ori_node)
		list.boxs[i] = target
		local node = target[list.template_head]
		gui.set_enabled(node, false)
		gui.set_position(node, pos)
	end
	gui.delete_node(ori_node)
	-- --------------------------------------------------
	-- init node clone and set position

	-- page_num: now page number
	-- params: parameters
	-- LIMIT: view list limit
	-- --------------------------------------------------
	function list.update_list(page_num, params)
		list.begin_num = change_page(page_num, #params, list.limit)
		for i = 1, list.limit do
			local p_num = i + list.begin_num
			if params[p_num] then
				write(list, i, params[p_num])
			else
				hide(list, i)
			end
		end
	end
	-- --------------------------------------------------
	-- init node clone and set position

	-- page_num: now page number
	-- params: parameters
	-- LIMIT: view list limit
	-- --------------------------------------------------
	function list.check(selected)
		local select_num = -1
		if selected  > list.begin_num and selected  <= (list.begin_num + list.limit) then
			select_num = ((selected - 1) % list.limit) + 1
		end
		return select_num
	end
	return list
end

return M