import os
import math as m
import gg
import gx

const tile_size = 90
const gray_text_cfg = gx.TextCfg{
	color: gx.gray
	size: 30
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}
const macro_mode_cfg = gx.TextCfg{
	color: gx.Color{0, 198, 68, 200}
	size: 40
	align: .center
	vertical_align: .middle
	bold: true
	family: 'agency fb'
}
const valid_macro_cfg = gx.TextCfg{
	color: gx.green
	size: 30
	align: .center
	vertical_align: .middle
	bold: true
	family: 'agency fb'
}
const notvalid_macro_cfg = gx.TextCfg{
	color: gx.red
	size: 30
	align: .center
	vertical_align: .middle
	bold: true
	family: 'agency fb'
}

enum Direction {
	no
	up
	down
	left
	right
	frontcav_upl
	frontcav_upr
	frontcav_downl
	frontcav_downr
	frontcav_leftu
	frontcav_leftd
	frontcav_rightu
	frontcav_rightd
	extcav_upl
	extcav_upr
	extcav_downl
	extcav_downr
	extcav_leftu
	extcav_leftd
	extcav_rightu
	extcav_rightd
}

struct MacroMove {
	rel_x int // relative x
	rel_y int // positive is up
	dir Direction
}

struct App {
mut:
	gg &gg.Context = unsafe { nil }

	base_click_x  f64
	base_click_y  f64
	click_x       f64
	click_y       f64
	block_click_x f64
	block_click_y f64
	mouse_x       f64
	mouse_y       f64
	clicked       bool

	macros_spaces [][][]int = [][][]int{}
	macros_moves [][]MacroMove = []
	macro_mode bool
}

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		create_window: true
		height: 600
		width: 600
		window_title: 'U'
		user_data: app
		bg_color: gx.white
		frame_fn: on_frame
		event_fn: on_event
		sample_count: 5
		// ui_mode: true
	)

	app.macros_spaces << [][]int{}
	col := os.input("Nb columns >").int()
	lines := os.input("Nb lines >").int()
	for i in 0..lines {
		app.macros_spaces[0] << []int{}
		for _ in 0..col {
			app.macros_spaces[0][i] << -1
		}
	}

	app.gg.run()

	if app.macros_moves.len > 0 {
		mut file := os.create('save_moves_macro-rename_it') or {panic(err)}
		for mov in app.macros_moves[0] {
			file.write_struct(mov) or {panic(err)}
		}
		file.close()
		println("Saved")
		os.write_file("macrospaces-rename","spaces=${app.macros_spaces[0]}") or {panic(err)}
	}
}

fn on_frame(mut app App) {
	// Draw
	app.gg.begin()
	app.show_actual_macro()
	app.highlights()
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	app.mouse_x = e.mouse_x
	app.mouse_y = e.mouse_y
	match e.typ {
		.key_down {
			match e.key_code {
				.escape {
					app.gg.quit()
				}
				.backspace {
					app.macros_spaces = [[[-1, -1], [-1, -1], [-1, -1]]]
					app.base_click_x = 0
					app.base_click_y = 0
					app.click_x = 0
					app.click_y = 0
					app.block_click_x = 0
					app.block_click_y = 0
					app.mouse_x = 0
					app.mouse_y = 0
					app.clicked = false
				}
				else {}
			}
		}
		.mouse_down {
			match e.mouse_button {
				.left {
					app.clicked = true
					app.click_x = e.mouse_x
					app.click_y = e.mouse_y
					app.block_click_x, app.block_click_y = app.mouse_coord_to_block_coord()
				}
				else {}
			}
		}
		.mouse_up {
			match e.mouse_button {
				.left {
					app.clicked = false
					sec_block_click_x, sec_block_click_y := app.mouse_coord_to_block_coord()
					if sec_block_click_x >= 0 && sec_block_click_y >= 0 && app.macros_spaces[0].len > sec_block_click_y && app.macros_spaces[0].len > app.block_click_y && app.macros_spaces[0][int(sec_block_click_y)].len > sec_block_click_x && app.macros_spaces[0][int(app.block_click_y)].len > app.block_click_x {
						if app.block_click_x != sec_block_click_x || app.block_click_y != sec_block_click_y {
							if app.macros_moves.len < 0 + 1 {
								app.macros_moves << []MacroMove{}
							}
							mov := app.new_macro_move(e.mouse_x, e.mouse_y)
							_, _, rel_x, rel_y := get_move_from_dir(mov.dir)
							if mov.dir != .no && app.block_click_y + rel_y >= 0 && app.block_click_x + rel_x >= 0 && app.macros_spaces[0].len > app.block_click_y + rel_y && app.macros_spaces[0][int(app.block_click_y)].len > app.block_click_x + rel_x {
								println(mov)
								app.macros_moves[0] << mov
							}
						}else {
							app.macros_spaces[0][app.macros_spaces[0].len-1-int(sec_block_click_y)][int(sec_block_click_x)] += 1
							if app.macros_spaces[0][app.macros_spaces[0].len-1-int(sec_block_click_y)][int(sec_block_click_x)] > 1 {
								app.macros_spaces[0][app.macros_spaces[0].len-1-int(sec_block_click_y)][int(sec_block_click_x)] = -1
							}
						}
					}
				}
				else {}
			}
		}
		else {}
	}
}

fn (mut app App) mouse_coord_to_block_coord() (f64, f64) {
	return m.floor((app.mouse_x) / tile_size), m.floor((app.mouse_y) / tile_size)
}

fn (mut app App) show_actual_macro() {
	if app.macros_spaces.len > 0 {
		tmpx, tmpy := 0, app.macros_spaces[0].len
		x, y := app.block_to_world_coords(tmpx, tmpy-1)
		app.gg.draw_text(int(x), int(y), 'M', macro_mode_cfg)
		for rel_y, line in app.macros_spaces[0] {
			for rel_x, value in line {
				x2, y2 := app.block_to_world_coords(tmpx+rel_x, tmpy-rel_y-1)
				if value == 1{
					tile_color := gx.Color{0, 255, 0, 100}
					app.gg.draw_rounded_rect_filled(x2 - tile_size * 0.5 + 1, y2 - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, tile_color)
				}else if value == 0 {
					tile_color := gx.Color{255, 0, 0, 100}
					app.gg.draw_rounded_rect_filled(x2 - tile_size * 0.5 + 1, y2 - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, tile_color)
				}else{
					tile_color := gx.Color{200, 200, 200, 100}
					app.gg.draw_rounded_rect_filled(x2 - tile_size * 0.5 + 1, y2 - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, tile_color)
				}	
			}
		}
		if app.macros_moves.len > 0 {
			for i, movem in app.macros_moves[0] {
				_, _, x2, y2 := get_move_from_dir(movem.dir)
				line_color := gx.Color{128, 128, 128, 128}
				start_x, start_y := app.block_to_world_coords(tmpx+movem.rel_x, tmpy-movem.rel_y-1)
				end_x, end_y := app.block_to_world_coords(tmpx+movem.rel_x+x2, tmpy-movem.rel_y+y2-1)
				app.gg.draw_line_with_config(end_x, end_y, start_x, start_y, gg.PenConfig{line_color, .solid, 5})
				app.gg.draw_line_with_config(start_x, start_y, end_x, end_y, gg.PenConfig{line_color, .solid, 5})	
				app.gg.draw_text(int(start_x) + 10, int(start_y) + 5, '$i', gray_text_cfg)
			}
		}
	}	
}

fn (mut app App) highlights() {
	if app.clicked {
		// Start block
		start_coo_x, start_coo_y := app.block_to_world_coords(app.block_click_x, app.block_click_y)

		// End block
		mut end_block_x, mut end_block_y := app.block_click_x, app.block_click_y // app.mouse_coord_to_block_coord()
		mut stack_block_x, mut stack_block_y := app.block_click_x, app.block_click_y
		dir := app.move_dir(f32(app.mouse_x), f32(app.mouse_y))
			//if app.block_click_x != sec_block_click_x || app.block_click_y != sec_block_click_y {
		if dir != .no {
			x1, y1, x2, y2 := get_move_from_dir(dir)
			stack_block_x += x1
			stack_block_y += y1
			end_block_x += x2
			end_block_y += y2
			if end_block_y >= 0 && end_block_x >= 0 && app.macros_spaces[0].len > app.block_click_x && app.macros_spaces[0].len > end_block_y && app.macros_spaces[0][int(end_block_y)].len > end_block_x && app.macros_spaces[0][int(end_block_y)].len > app.block_click_x {
				end_x, end_y := app.block_to_world_coords(end_block_x, end_block_y)
				stack_x, stack_y := app.block_to_world_coords(stack_block_x, stack_block_y)
				outline_color := gx.green
				app.gg.draw_rounded_rect_empty(end_x - tile_size * 0.5 + 1, end_y - tile_size * 0.5 + 1,
					tile_size - 2, tile_size - 2, 5, outline_color)
				stack_color := gx.green
				app.gg.draw_rounded_rect_empty(stack_x - tile_size * 0.5 + 1,
					stack_y - tile_size * 0.5 + 1, tile_size - 2, tile_size - 2, 5, stack_color)
				line_color := gx.green
				app.gg.draw_line_with_config(end_x, end_y, start_coo_x, start_coo_y, gg.PenConfig{line_color, .solid, 5})
				app.gg.draw_line_with_config(start_coo_x, start_coo_y, end_x, end_y, gg.PenConfig{line_color, .solid, 5})
				app.gg.draw_circle_filled(end_x, end_y, 10, line_color)
			}
		}
	}
}

fn (app App) block_to_world_coords(x f64, y f64) (f32, f32) {
	return f32(x * tile_size + tile_size * 0.5), f32(y * tile_size +
		tile_size * 0.5)
}