import math as m

fn block_to_array_coords(x f64, y f64) !(ArrayType, f64, f64) {
	if x * x < 10000 && y * y < 10000 {
		if x >= 0 { // r true
			if y > 0 { // b true
				return ArrayType.br, x, y - 1
			} else { // b false
				return ArrayType.tr, x, -y
			}
		} else { // r false
			if y > 0 { // b true
				return ArrayType.bl, -x - 1, y - 1
			} else { // b false
				return ArrayType.tl, -x - 1, -y
			}
		}
	}
	return error('out of bounds')
}

fn (app App) block_to_world_coords(x f64, y f64) (f32, f32) {
	return f32(x * tile_size + tile_size * 0.5 + app.viewport_x), f32(y * tile_size +
		tile_size * 0.5 + app.viewport_y)
}

fn (mut app App) mouse_coord_to_block_coord() (f64, f64) {
	return m.floor((app.mouse_x - app.viewport_x) / tile_size), m.floor((app.mouse_y - app.viewport_y) / tile_size)
}

fn (app App) check_array_occuped_in(atype ArrayType, x f64, y f64) bool {
	match atype {
		.tl { return app.tl[int(y)][int(x)] }
		.tr { return app.tr[int(y)][int(x)] }
		.br { return app.br[int(y)][int(x)] }
		.bl { return app.bl[int(y)][int(x)] }
	}
}

fn (app App) check_array_occuped_from_block_coords(i_x f64, i_y f64) bool {
	atype, x, y := block_to_array_coords(i_x, i_y) or { return false }
	return app.check_array_occuped_in(atype, x, y)
}

fn (mut app App) click(x f32, y f32) {
	app.click_x = x
	app.click_y = y
	app.block_click_x, app.block_click_y = app.mouse_coord_to_block_coord()
}
