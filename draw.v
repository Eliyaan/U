import math as m
import gg
import gx
import time

fn gradient(x int, freq int) u8 {
	xmod := x % (freq * 2)
	if xmod >= freq {
		return u8((freq * 2) - xmod)
	}
	return u8(xmod)
}

fn color_gradient(x f64, y f64) gx.Color {
	return gx.Color{gradient(int(y) + 200, 32) * 4 + 127, 127, gradient(int(x) + 200, 32) * 4 + 127, 255}
}

fn squish_gradient(x f64, y f64) f32 {
	return f32((gradient(int(x), 8) + gradient(int(y), 8)))
}

@[inline]
pub fn sigmoid(value f32) f32 {
	return f32(1 / (1 + m.exp(-value)))
}

fn (mut app App) draw_slime(x_pos f32, y_pos f32, x int, y int) {
	y_offset := sigmoid(squish_gradient(f64(x) * 1.5 + f64(time.ticks()) / 100.0, f64(y) * 1.5)/8.0)*16.0
	if x_pos >= -tile_size && x_pos < app.win_size.width {
		app.gg.draw_rounded_rect_filled(x_pos + semi_space, y_pos + semi_space + y_offset,
			slime_size, slime_size - y_offset, 5, color_gradient(x, y))
		app.gg.draw_circle_filled(x_pos + tile_size * 5 / 16, y_pos + tile_size / 2 + y_offset - 7,
			13, gx.black)
		app.gg.draw_circle_filled(x_pos + tile_size * 11 / 16, y_pos + tile_size / 2 + y_offset - 7,
			13, gx.black)
		app.gg.draw_circle_filled(x_pos + tile_size * 5 / 16, y_pos + tile_size * 2.3 / 5 + y_offset - 7,
			6.5, gx.white)
		app.gg.draw_circle_filled(x_pos + tile_size * 11 / 16, y_pos + tile_size * 2.3 / 5 +
			y_offset - 7, 6.5, gx.white)
	}
}

fn (mut app App) draw_slimes() {
	for y, line in app.bl {
		y_pos := f32((y + 1) * tile_size + 1 + app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32((-x - 1) * tile_size + 1 + app.viewport_x)
					app.draw_slime(x_pos, y_pos, x, y)
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
					app.draw_slime(x_pos, y_pos, x, y)
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
					app.draw_slime(x_pos, y_pos, x, y)
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
					app.draw_slime(x_pos, y_pos, x, y)
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
			outline_color := if app.check_array_occuped_from_block_coords(end_block_x,
				end_block_y)
			{
				gx.red
			} else {
				gx.green
			}
			app.gg.draw_rounded_rect_empty(end_x - tile_size * 0.5 + 1, end_y - tile_size * 0.5 + 1,
				tile_size - 2, tile_size - 2, 5, outline_color)
			_, _, end_y_array_coords := block_to_array_coords(0, end_block_y) or { return }
			stack_color := if app.check_array_occuped_from_block_coords(stack_block_x,
				stack_block_y)
			{
				gx.green
			} else {
				gx.red
			}
			app.gg.draw_rounded_rect_empty(stack_x - tile_size * 0.5 + 1,
				stack_y - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, stack_color)
			line_color := if !app.check_array_occuped_from_block_coords(end_block_x, end_block_y)
				&& app.check_array_occuped_from_block_coords(stack_block_x, stack_block_y)
				&& app.energy >= cout_deplacement(end_y_array_coords) {
				gx.green
			} else {
				gx.red
			}
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
