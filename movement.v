fn (mut app App) move(x f32, y f32) {
	if (app.click_x - x)*(app.click_x - x) + (app.click_y - y)*(app.click_y - y) > tile_size*tile_size {
		if (app.click_y - y) > m.abs(app.click_x - x) { // direction -> up
			app.mvt_towards(Direction.up)
		} else if (y - app.click_y) > m.abs(app.click_x - x) { // direction -> down
			app.mvt_towards(Direction.down)
		} else if (app.click_x - x) > m.abs(app.click_y - y) { // direction -> left
			app.mvt_towards(Direction.left)
		} else if (x - app.click_x) > m.abs(app.click_y - y) { // direction -> right
			app.mvt_towards(Direction.right)
		}
	}
}

fn (mut app App) place_in(atype ArrayType, x f64, y f64, value bool) {
	match atype {
		.tl {app.tl[int(y)][int(x)] = value}
		.tr {app.tr[int(y)][int(x)] = value}
		.br {app.br[int(y)][int(x)] = value}
		.bl {app.bl[int(y)][int(x)] = value}
	}
}

fn (mut app App) mvt_towards(dir Direction) {
	match dir {
		.up {app.cardinal_mvts(0, -1, 0, -2)}
		.down{app.cardinal_mvts(0, 1, 0, 2)}
		.left{app.cardinal_mvts(-1, 0, -2, 0)}
		.right{app.cardinal_mvts(1, 0, 2, 0)}
	}
}

fn (mut app App) cardinal_mvts(x1 int, y1 int, x2 int, y2 int) {  // xs and ys in block coords
	start_atype, start_x, start_y := block_to_array_coords(app.block_click_x, app.block_click_y) or {return}
	if app.check_array_occuped_in(start_atype, start_x, start_y) {
		stack_atype, stack_x, stack_y := block_to_array_coords(app.block_click_x+x1, app.block_click_y+y1) or {return}
		if app.check_array_occuped_in(stack_atype, stack_x, stack_y) {
			end_atype, end_x, end_y := block_to_array_coords(app.block_click_x+x2, app.block_click_y+y2) or {return}
			if app.energy >= cout_deplacement(end_y) && !app.check_array_occuped_in(end_atype, end_x, end_y) {
				app.place_in(start_atype, start_x, start_y, false)
				app.place_in(stack_atype, stack_x, stack_y, false)
				app.place_in(end_atype, end_x, end_y, true)
				coo_x := int(m.round(app.block_click_x))
				coo_x1 := int(m.round(app.block_click_x+x1))
				coo_x2 := int(m.round(app.block_click_x+x2))
				y_y2 := -int(app.block_click_y+y2)
				if y_y2 >= 0 {
					app.slimes_per_layers[y_y2] += 1
					if app.right_limit_per_layers[y_y2] < coo_x2 {
						app.right_limit_per_layers[y_y2] = coo_x2

					}
					if app.left_limit_per_layers[y_y2] > coo_x2 {
						app.left_limit_per_layers[y_y2] = coo_x2
					}
				}
				y_y1 := -int(app.block_click_y+y1)
				if y_y1 >= 0 {
					app.slimes_per_layers[y_y1] -= 1
					if app.slimes_per_layers[y_y1] == 0 {
						app.right_limit_per_layers[y_y1] = -1000
						app.left_limit_per_layers[y_y1] = 1000
					} else if app.left_limit_per_layers[y_y1] == coo_x1 {
						mut nb := 1000
						if coo_x1 < 0 {
							for i, slime in app.tl[y_y1][0..-coo_x1] {
								if slime {
									nb = -i-1
								}
							}
							if nb == 1000 {
								for i, slime in app.tr[y_y1][0..app.right_limit_per_layers[y_y1]+1] {
									if slime {
										nb = i
										break
									}
								}
							}
						} else {
							for i, slime in app.tr[y_y1][coo_x1..app.right_limit_per_layers[y_y1]+1] {
								if slime {
									nb = i+coo_x1
									break
								}
							}
						}
						app.left_limit_per_layers[y_y1] = nb
					} else if app.right_limit_per_layers[y_y1] == coo_x1 {
						mut nb := -1000
						if coo_x1 > 0 {
							for i, slime in app.tr[y_y1][0..coo_x1] {
								if slime {
									nb = i
								}
							}
							if nb == -1000 {
								for i, slime in app.tl[y_y1][0..-app.left_limit_per_layers[y_y1]+1] {
									if slime {
										nb = -i-1
										break
									}
								}
							}
						} else {
							for i, slime in app.tl[y_y1][-coo_x1..-app.left_limit_per_layers[y_y1]+1] {
								if slime {
									nb = -i-1 + coo_x1
									break
								}
							}
						}
						
						app.right_limit_per_layers[y_y1] = nb
					}
				}
				y_y := -int(app.block_click_y)
				if y_y >= 0 {
					app.slimes_per_layers[y_y] -= 1
					if app.slimes_per_layers[y_y] == 0 {
						app.right_limit_per_layers[y_y] = -1000
						app.left_limit_per_layers[y_y] = 1000
					} else if app.left_limit_per_layers[y_y] == coo_x {
						mut nb := 1000
						if coo_x < 0 {
							for i, slime in app.tl[y_y][0..-coo_x] { 
								if slime {
									nb = -i-1
								}
							}
							if nb == 1000 {
								for i, slime in app.tr[y_y][0..app.right_limit_per_layers[y_y]+1] {
									if slime {
										nb = i
										break
									}
								}
							}
						} else {
							for i, slime in app.tr[y_y][coo_x..app.right_limit_per_layers[y_y]+1] {
								if slime {
									nb = i+coo_x
									break
								}
							}
						}
						app.left_limit_per_layers[y_y] = nb
					} else if app.right_limit_per_layers[y_y] == coo_x {
						mut nb := -1000
						if coo_x > 0 {
							for i, slime in app.tr[y_y][0..coo_x] {
								if slime {
									nb = i
								}
							}
							if nb == -1000 {
								for i, slime in app.tl[y_y][0..-app.left_limit_per_layers[y_y]+1] {
									if slime {
										nb = -i-1
										break
									}
								}
							}
						} else {
							for i, slime in app.tl[y_y][-coo_x..-app.left_limit_per_layers[y_y]+1] {
								if slime {
									nb = -i-1 + coo_x
									break
								}
							}
						}
						
						app.right_limit_per_layers[y_y] = nb
					}
				}
				app.energy -= m.pow(2, m.abs(end_y))
			}
		}
	}
}

