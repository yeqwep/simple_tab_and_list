local M = {}

M.action_id_touch       = hash("touch")
M.action_id_multi       = hash("multi")

function M.create(node, callback)
	local button = {pressed = false, hover = false}
	local fb = gui.get_color(node)
	fb.w = 0.92
	local fb_dark = vmath.vector4(fb.x - 0.3,fb.y - 0.3,fb.z - 0.3,0.8)
	gui.set_color(node,fb_dark)
	-- define the input handler function
	function button.on_input(action_id, action)
		if gui.is_enabled(node) then
			-- mouse/finger over the button?
			local over = gui.pick_node(node, action.x, action.y)
			if over then
				button.hover = true
				gui.cancel_animation(node, "color")
				gui.set_color(node,fb)
				-- gui.animate(node, gui.PROP_COLOR, fb, gui.EASING_INOUTCUBIC, 0.05, 0, nil, gui.PLAYBACK_ONCE_FORWARD)
			elseif over == false and button.hover then
				button.hover = false
				-- gui.set_color(node,fb_dark)
				gui.animate(node, gui.PROP_COLOR, fb_dark, gui.EASING_INOUTCUBIC, 0.46, 0, nil, gui.PLAYBACK_ONCE_FORWARD)
			end
			if button.hover and action.pressed and action_id == M.action_id_touch then
				button.pressed = true
				gui.cancel_animation(node, gui.PROP_COLOR)
				gui.set_scale(node,vmath.vector3(0.95,0.95,1))
			elseif action.released and button.pressed and action_id == M.action_id_touch then
				button.pressed = false
				gui.set_color(node,fb_dark)
				-- gui.animate(node, gui.PROP_COLOR, fb_dark, gui.EASING_INOUTCUBIC, 1.6, 0, nil, gui.PLAYBACK_LOOP_PINGPONG)
				gui.set_scale(node,vmath.vector3(1,1,1))
				if button.hover then
					-- sound.play("main:/sound#button")
					callback(button)
				end
			end
		end
	end
	return button
end
function M.create_toggle(node, flag, callback)
	local button = {pressed = false, hover = false}
	local anim = {on = hash("b_on"), off = hash("b_off")}

	gui.play_flipbook(node, flag and anim.on or anim.off)

	function button.on_input(action_id, action, flag)
		local over = gui.pick_node(node, action.x, action.y)
		if over and action.pressed and action_id == M.action_id_touch then
			button.pressed = true
		elseif action.released and button.pressed and action_id == M.action_id_touch then
			button.pressed = false
			if over then
				flag = not flag
				gui.play_flipbook(node, flag and anim.on or anim.off)
				callback(button,flag)
			end
		end
	end

	return button
end
function M.create_toggle_blank(node, flag, callback)
	local button = {pressed = false, hover = false}
	local fb = gui.get_color(node)
	fb.w = 0.92
	local fb_dark = vmath.vector4(fb.x - 0.3,fb.y - 0.3,fb.z - 0.3,0.7)
	local col = {on = fb, off = fb_dark}
	gui.set_color(node,flag and col.on or col.off)

	function button.on_input(action_id, action, flag)
		local over = gui.pick_node(node, action.x, action.y)
		if over and action.pressed and action_id == M.action_id_touch then
			button.pressed = true
			gui.cancel_animation(node, gui.PROP_COLOR)
			gui.set_color(node,flag and col.on or col.off)
		elseif action.released and button.pressed and action_id == M.action_id_touch then
			button.pressed = false
			if over then
				-- flag = not flag
				gui.set_color(node,fb)
				callback(button,flag)
			end
		end
	end
	return button
end
-- --------------------------------------------------
-- tag button
-- node_id : node name
-- node_num : nodes
-- select_num : select node number
-- callback : callback function
-- --------------------------------------------------
function M.create_tags(node_id, node_num, select_num, callback)
	local button = {}
	local col = {}
	local fb = vmath.vector4(1,1,1, 0.7)
	local fb_dark = vmath.vector4(fb.x / 3,fb.y / 3,fb.z / 3,fb.w)
	local fb_hover = vmath.vector4(fb.x / 2,fb.y / 2,fb.z / 2,fb.w)
	col = {on = fb, off = fb_dark, hover = fb_hover}
	for i = 1, node_num do
		local node = gui.get_node(node_id .. i)
		button[i] = {node = node, hover = false, pressed = false, select = false}
		gui.set_color(button[i]["node"],col.off)
	end
	function button.on_input(action_id, action)
		for j = 1, node_num do
			if gui.is_enabled(button[j]["node"]) then
				local over = gui.pick_node(button[j]["node"], action.x, action.y)
				if button[j]["select"] == false then
					if over and button[j]["hover"] == false then
						button[j]["hover"] = true
						gui.set_color(button[j]["node"],col.hover)
					elseif over == false and button[j]["hover"] then
						button[j]["hover"] = false
						gui.set_color(button[j]["node"],col.off)
					end
				end
				if over and action.pressed and action_id == M.action_id_touch then
					button[j]["pressed"] = true
				elseif action.released and button[j]["pressed"] and action_id == M.action_id_touch then
					button[j]["pressed"] = false
					if over and not button[j]["select"] then
						for k = 1, node_num do
							local push_flag = (k == j)
							button[k]["select"] = push_flag
							gui.set_color(button[k]["node"],push_flag and col.on or col.off)
						end
						callback(button,j)
						-- sound.play("main:/sound#button")
						break
					end
				end
			end
		end
	end
	-- 選択中のボタン変更
	function button.select_change(select_num)
		for i = 1, node_num do
			local select_flag = (i == select_num)
			button[i]["select"] = select_flag
			gui.set_color(button[i]["node"],select_flag and col.on or col.off)
		end
	end
	return button
end
-- --------------------------------------------------
-- list buttons
-- nodes : nodes
-- template_back : template_back name
-- callback : callback function
-- --------------------------------------------------
function M.create_list(nodes, template_back, callback)
	local button = {}
	local col = {}
	local fb = vmath.vector4(1,1,1, 0.46)
	local fb_dark = vmath.vector4(fb.x / 4,fb.y / 4,fb.z / 4, 0.9)
	local fb_hover = vmath.vector4(1,1,1, fb.w/2)
	col = {on = fb, off = fb_dark, hover = fb_hover}
	for i,var in ipairs(nodes) do
		local node = var[template_back]
		button[i] = {node = node, hover = false, pressed = false, select = false}
		gui.set_color(button[i]["node"],col.off)
	end
	function button.on_input(action_id, action)
		for j = 1, #nodes do
			local parent = gui.get_parent(button[j]["node"])
			if gui.is_enabled(parent) then
				local over = gui.pick_node(button[j]["node"], action.x, action.y)
				if button[j]["select"] == false then
					if over and button[j]["hover"] == false then
						print(j)
						button[j]["hover"] = true
						gui.set_color(button[j]["node"],col.hover)
					elseif over == false and button[j]["hover"] then
						button[j]["hover"] = false
						gui.set_color(button[j]["node"],col.off)
					end
				end
				if over and action.pressed and action_id == M.action_id_touch then
					button[j]["pressed"] = true
				elseif action.released and button[j]["pressed"] and action_id == M.action_id_touch then
					button[j]["pressed"] = false
					if over and not button[j]["select"] then
						for k = 1, #nodes do
							local push_flag = (k == j)
							button[k]["select"] = push_flag
							gui.set_color(button[k]["node"],push_flag and col.on or col.off)
						end
						callback(button,j)
						-- sound.play("main:/sound#button")
						break
					end
				end
			end
		end
	end
	function button.select_check(select_num)
		for i = 1, #nodes do
			local select_flag = (i == select_num)
			button[i]["select"] = select_flag
			gui.set_color(button[i]["node"],select_flag and col.on or col.off)
		end
	end
	return button
end
return M