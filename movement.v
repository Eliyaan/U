import math as m

fn (mut app App) move(x f32, y f32) {
	app.mvt_towards(app.move_dir(x, y), int(app.block_click_x), int(app.block_click_y))
}

fn (app App) move_dir(x f32, y f32) Direction {
	if (app.click_x - x) * (app.click_x - x) + (app.click_y - y) * (app.click_y - y) > tile_size * tile_size {
		if (app.click_y - y) > m.abs(app.click_x - x) { // direction -> up
			if (app.click_y - y) / 4.0 < (app.click_x - x) {
				if (app.click_y - y) / 1.5 > (app.click_x - x) {
					return Direction.frontcav_upl
				} else {
					return Direction.extcav_upl
				}
			} else if (app.click_y - y) / 4.0 < (x - app.click_x) {
				if (app.click_y - y) / 1.5 > (x - app.click_x) {
					return Direction.frontcav_upr
				} else {
					return Direction.extcav_upr
				}
			} else {
				return Direction.up
			}
		} else if (y - app.click_y) > m.abs(app.click_x - x) { // direction -> down
			if (y - app.click_y) / 4.0 < (app.click_x - x) {
				if (y - app.click_y) / 1.5 > (app.click_x - x) {
					return Direction.frontcav_downl
				} else {
					return Direction.extcav_downl
				}
			} else if (y - app.click_y) / 4.0 < (x - app.click_x) {
				if (y - app.click_y) / 1.5 > (x - app.click_x) {
					return Direction.frontcav_downr
				} else {
					return Direction.extcav_downr
				}
			} else {
				return Direction.down
			}
		} else if (app.click_x - x) > m.abs(app.click_y - y) { // direction -> left
			if (app.click_x - x) / 4.0 < (app.click_y - y) {
				if (app.click_x - x) / 1.5 > (app.click_y - y) {
					return Direction.frontcav_leftu
				} else {
					return Direction.extcav_leftu
				}
			} else if (app.click_x - x) / 4.0 < (y - app.click_y) {
				if (app.click_x - x) / 1.5 > (y - app.click_y) {
					return Direction.frontcav_leftd
				} else {
					return Direction.extcav_leftd
				}
			} else {
				return Direction.left
			}
		} else if (x - app.click_x) > m.abs(app.click_y - y) { // direction -> right
			if (x - app.click_x) / 4.0 < (app.click_y - y) {
				if (x - app.click_x) / 1.5 > (app.click_y - y) {
					return Direction.frontcav_rightu
				} else {
					return Direction.extcav_rightu
				}
				return Direction.frontcav_rightu
			} else if (x - app.click_x) / 4.0 < (y - app.click_y) {
				if (x - app.click_x) / 1.5 > (y - app.click_y) {
					return Direction.frontcav_rightd
				} else {
					return Direction.extcav_rightd
				}
			} else {
				return Direction.right
			}
		}
	}
	return Direction.no
}

fn (mut app App) place_in(atype ArrayType, x f64, y f64, value bool) {
	match atype {
		.tl { app.tl[int(y)][int(x)] = value }
		.tr { app.tr[int(y)][int(x)] = value }
		.br { app.br[int(y)][int(x)] = value }
		.bl { app.bl[int(y)][int(x)] = value }
	}
}

fn (mut app App) mvt_towards(dir Direction, block_x int, block_y int) {
	if dir != .no {
		x1, y1, x2, y2 := get_move_from_dir(dir)
		app.mvts(x1, y1, x2, y2, block_x, block_y)
	}
}

fn get_move_from_dir(dir Direction) (int, int, int, int) {
	match dir {
		.no { return 0, 0, 0, 0 }
		.up { return 0, -1, 0, -2 }
		.down { return 0, 1, 0, 2 }
		.left { return -1, 0, -2, 0 }
		.right { return 1, 0, 2, 0 }
		.frontcav_upl { return 0, -1, -1, -2 }
		.frontcav_upr { return 0, -1, 1, -2 }
		.frontcav_downl { return 0, 1, -1, 2 }
		.frontcav_downr { return 0, 1, 1, 2 }
		.frontcav_leftu { return -1, 0, -2, -1 }
		.frontcav_leftd { return -1, 0, -2, 1 }
		.frontcav_rightu { return 1, 0, 2, -1 }
		.frontcav_rightd { return 1, 0, 2, 1 }
		.extcav_upl { return -1, -1, -1, -2 }
		.extcav_upr { return 1, -1, 1, -2 }
		.extcav_downl { return -1, 1, -1, 2 }
		.extcav_downr { return 1, 1, 1, 2 }
		.extcav_leftu { return -1, -1, -2, -1 }
		.extcav_leftd { return -1, 1, -2, 1 }
		.extcav_rightu { return 1, -1, 2, -1 }
		.extcav_rightd { return 1, 1, 2, 1 }
	}
}

fn (mut app App) mvts(x1 int, y1 int, x2 int, y2 int, block_x int, block_y int) { // xs and ys in block coords
	start_atype, start_x, start_y := block_to_array_coords(block_x, block_y) or {return}
	if app.check_array_occuped_in(start_atype, start_x, start_y) {
		stack_atype, stack_x, stack_y := block_to_array_coords(block_x + x1,
			block_y + y1) or { return }
		if app.check_array_occuped_in(stack_atype, stack_x, stack_y) {
			end_atype, end_x, end_y := block_to_array_coords(block_x + x2,
				block_y + y2) or { return }
			if app.energy >= cout_deplacement(end_y)
				&& !app.check_array_occuped_in(end_atype, end_x, end_y) {
				app.place_in(start_atype, start_x, start_y, false)
				app.place_in(stack_atype, stack_x, stack_y, false)
				app.place_in(end_atype, end_x, end_y, true)
				y_y2 := -(block_y + y2)
				if y_y2 >= 0 {
					app.slimes_per_layers[y_y2] += 1
				}
				y_y1 := -(block_y + y1)
				if y_y1 >= 0 {
					app.slimes_per_layers[y_y1] -= 1
				}
				y_y := -block_y
				if y_y >= 0 {
					app.slimes_per_layers[y_y] -= 1
				}
				app.energy -= m.pow(2, m.abs(end_y))
			}
		}
	}
}
