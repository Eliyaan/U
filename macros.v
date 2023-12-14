import gg
import gx

fn (mut app App) cout_macro() f64 {
	_, pos_y := app.mouse_coord_to_block_coord()
	mut cout := 0
	for mvt in app.macros_moves[app.actual_macro] {
		_, _, _, end_y := get_move_from_dir(mvt.dir)
		cout += cout_deplacement(pos_y + end_y)
	}
	return cout
}

fn (mut app App) check_macro_valid() {  // and do it xD
	pos_x, pos_y := app.mouse_coord_to_block_coord()
	mut valid := true
	outer: for y, line in app.macros_spaces[app.actual_macro] {
		for x, value in line {
			if value == 1 {
				if !app.check_array_occuped_from_block_coords(pos_x + x, pos_y - y) {
					valid = false
					break outer
				}
			} else if value == 0 {
				if app.check_array_occuped_from_block_coords(pos_x + x, pos_y - y) {
					valid = false
					break outer
				}
			}
		}
	}
	if app.cout_macro() > app.energy {
		valid = false
	}
	if valid {
		for movem in app.macros_moves[app.actual_macro] {
			app.mvt_towards(movem.dir, int(pos_x + movem.rel_x), int(pos_y - movem.rel_y))
		}
	}
}

fn (mut app App) show_actual_macro() {
	tmpx, tmpy := app.mouse_coord_to_block_coord()
	x, y := app.block_to_world_coords(tmpx, tmpy)
	app.gg.draw_text(int(x), int(y), 'M$app.actual_macro', macro_mode_cfg)
	text_cfg := if app.cout_macro() <= app.energy {valid_macro_cfg} else {notvalid_macro_cfg}
	app.gg.draw_text(int(x), int(y)+tile_size/2+7, '${app.cout_macro()}', text_cfg)
	for rel_y, line in app.macros_spaces[app.actual_macro] {
		for rel_x, value in line {
			x2, y2 := app.block_to_world_coords(tmpx+rel_x, tmpy-rel_y)
			if value == 1{
				tile_color := if !app.check_array_occuped_from_block_coords(tmpx + rel_x, tmpy - rel_y) {
					gx.Color{255, 0, 0, 100}
				}else{
					gx.Color{0, 255, 0, 100}
				}
				app.gg.draw_rounded_rect_filled(x2 - tile_size * 0.5 + 1, y2 - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, tile_color)
			}else if value == 0 {
				tile_color := if app.check_array_occuped_from_block_coords(tmpx + rel_x, tmpy - rel_y) {
					gx.Color{255, 0, 0, 100}
				}else{
					gx.Color{0, 255, 0, 100}
				}
				app.gg.draw_rounded_rect_filled(x2 - tile_size * 0.5 + 1, y2 - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, tile_color)
			}			
		}
	}
	for i, movem in app.macros_moves[app.actual_macro] {
		_, _, x2, y2 := get_move_from_dir(movem.dir)
		line_color := gx.Color{128, 128, 128, 128}
		start_x, start_y := app.block_to_world_coords(tmpx+movem.rel_x, tmpy-movem.rel_y)
		end_x, end_y := app.block_to_world_coords(tmpx+movem.rel_x+x2, tmpy-movem.rel_y+y2)
		app.gg.draw_line_with_config(end_x, end_y, start_x, start_y, gg.PenConfig{line_color, .solid, 5})
		app.gg.draw_line_with_config(start_x, start_y, end_x, end_y, gg.PenConfig{line_color, .solid, 5})	
		app.gg.draw_text(int(start_x) + 10, int(start_y) + 5, '$i', gray_text_cfg)
	}
}