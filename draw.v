import gg
import gx

fn (mut app App) draw_slimes() {
	for y, line in app.bl {
		y_pos := f32((y + 1) * tile_size + 1 + app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32((-x - 1) * tile_size + 1 + app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size - 2, tile_size - 2,
							5, tile_color)
					}
				}
			}
		}
	}
	for y, line in app.br {
		y_pos := f32((y + 1) * tile_size + 1 + app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32(x * tile_size + 1 + app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size - 2, tile_size - 2,
							5, tile_color)
					}
				}
			}
		}
	}
	for y, line in app.tr {
		y_pos := f32(-y * tile_size + 1 + app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32(x * tile_size + 1 + app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size - 2, tile_size - 2,
							5, tile_color)
					}
				}
			}
		}
	}
	for y, line in app.tl {
		y_pos := f32(-y * tile_size + 1 + app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32((-x - 1) * tile_size + 1 + app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size - 2, tile_size - 2,
							5, tile_color)
					}
				}
			}
		}
	}
}

fn (mut app App) highlights() {
	if app.clicked
		&& app.check_array_occuped_from_block_coords(app.block_click_x, app.block_click_y) {
		// Start block
		start_coo_x, start_coo_y := app.block_to_world_coords(app.block_click_x, app.block_click_y)

		// End block
		mut end_block_x, mut end_block_y := app.block_click_x, app.block_click_y // app.mouse_coord_to_block_coord()
		mut stack_block_x, mut stack_block_y := app.block_click_x, app.block_click_y
		dir := app.move_dir(f32(app.mouse_x), f32(app.mouse_y))
		if dir != .no {
			x1, y1, x2, y2 := get_move_from_dir(dir)
			stack_block_x += x1
			stack_block_y += y1
			end_block_x += x2
			end_block_y += y2
			end_x, end_y := app.block_to_world_coords(end_block_x, end_block_y)
			stack_x, stack_y := app.block_to_world_coords(stack_block_x, stack_block_y)
			outline_color := if app.check_array_occuped_from_block_coords(end_block_x, end_block_y) { gx.red } else { gx.green }
			app.gg.draw_rounded_rect_empty(end_x - tile_size * 0.5 + 1, end_y - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, outline_color)
			_, _, end_y_array_coords := block_to_array_coords(0, end_block_y) or { return }
			stack_color := if app.check_array_occuped_from_block_coords(stack_block_x, stack_block_y) { gx.green } else { gx.red }
			app.gg.draw_rounded_rect_empty(stack_x - tile_size * 0.5 + 1,
				stack_y - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, stack_color)
			line_color := if !app.check_array_occuped_from_block_coords(end_block_x, end_block_y) && app.check_array_occuped_from_block_coords(stack_block_x, stack_block_y) && app.energy >= cout_deplacement(end_y_array_coords) { gx.green } else { gx.red }
			app.gg.draw_line_with_config(end_x, end_y, start_coo_x, start_coo_y, gg.PenConfig{line_color, .solid, 5})
			app.gg.draw_line_with_config(start_coo_x, start_coo_y, end_x, end_y, gg.PenConfig{line_color, .solid, 5})
			app.gg.draw_circle_filled(end_x, end_y, 10, line_color)
			app.gg.draw_text(int(start_coo_x) + 10, int(start_coo_y) + 5, '${cout_deplacement(end_y_array_coords)}',
				if app.energy >= cout_deplacement(end_y_array_coords) {
				valid_text_cfg
			} else {
				invalid_text_cfg
			})
		}
	}
}
