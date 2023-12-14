import math as m

fn (mut app App) new_macro_move(x f32, y f32) MacroMove {
	return MacroMove{int(app.block_click_x), app.macros_spaces[0].len-int(app.block_click_y)-1, app.move_dir(x, y)}
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