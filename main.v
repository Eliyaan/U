module main

import toml
import os
import gg
import math as m

/*
TODO:
- Juice icone énergie qui boing
- autre déplacements ?
- lvl des slimes (combien ils en ont stack) (changement alpha)
- voir pour les niveaux requis etc
- macros lvls requis
- débloque 1 nouvelle couleur par ligne
*/

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		create_window: true
		fullscreen: true
		window_title: 'U'
		user_data: app
		bg_color: gray
		frame_fn: on_frame
		event_fn: on_event
		sample_count: 5
		// ui_mode: true
	)
	mut j := 0
	for {
		mut file := os.open('saves_macros/save_moves_macro$j') or { break }
		app.macros_moves << []MacroMove{}
		mut stru := MacroMove{}
		for {
			file.read_struct(mut stru) or {break}
			app.macros_moves[j] << stru
		}
		file.close()
		f := toml.parse_file('saves_macros/macrospaces$j') or { panic(err) }
		app.macros_spaces << [][]int{}
		for i, a in f.value('spaces').array() {
			app.macros_spaces[j] << []int{}
			for value in a.array() {
				app.macros_spaces[j][i] << value.int()
			}
		}
		j += 1
	}
	save := toml.parse_file('state_save') or {panic(err)}
	app.energy = save.value("energy").f64()
	app.slimes_per_layers = save.value('slimes_per_layers').array().map(it.int())
	app.tl = save.value('tl').array().map(it.array().map(it.bool()))
	app.tr = save.value('tr').array().map(it.array().map(it.bool()))
	app.bl = save.value('bl').array().map(it.array().map(it.bool()))
	app.br = save.value('br').array().map(it.array().map(it.bool()))

	/*
	mut file := os.create('save_macros') or {panic(err)}
	file.write_struct(MacroMove{1, 0, .extcav_upl}) or {panic(err)}
	file.write_struct(MacroMove{0, 0, .extcav_upr}) or {panic(err)}
	file.close()
	*/


	// lancement du programme/de la fenêtre
	app.gg.run()
	os.write_file("state_save", 'energy=$app.energy\nslimes_per_layers=$app.slimes_per_layers\ntl=$app.tl\ntr=$app.tr\nbl=$app.bl\nbr=$app.br') or {panic(err)}
}

fn on_frame(mut app App) {
	app.win_size = app.gg.window_size()
	if app.viewport_x == 0 && app.viewport_y == 0 {
		app.viewport_x = app.win_size.width / 2
		app.viewport_y = app.win_size.height / 2
	} else if !app.clicked {
		if app.mouse_x > app.win_size.width - 100 {
			app.viewport_x -= (100 - (app.win_size.width - app.mouse_x)) / 10.0
		}
		if app.mouse_x < 100 {
			app.viewport_x += (100 - (app.mouse_x)) / 10.0
		}
		if app.mouse_y > app.win_size.height - 100 {
			app.viewport_y -= (100 - (app.win_size.height - app.mouse_y)) / 10.0
		}
		if app.mouse_y < 100 {
			app.viewport_y += (100 - (app.mouse_y)) / 10.0
		}
	}
	// Draw
	app.gg.begin()
	app.gg.draw_text(app.win_size.width/2, app.win_size.height/2, 'U', u_logo_cfg)
	app.draw_slimes()
	app.highlights()
	mut total_new_ener := 0.0
	for i, nb_slimes in app.slimes_per_layers {
		if nb_slimes > 0 {
			new_ener := app.energy_produc(i, nb_slimes)
			app.energy += new_ener
			total_new_ener += new_ener
			app.gg.draw_text(10, int((-i) * tile_size + 1 + app.viewport_y), '${m.round_sig(new_ener * 60,
				2)}/s  (${nb_slimes} / ${i + 1})', energy_gain_cfg)
		}
	}
	if app.macro_mode {
		app.show_actual_macro()
	}
	
	app.gg.draw_text(15, 15, '${m.round_sig(app.energy, 1)} (+ ${m.round_sig(total_new_ener * 60, 1)}/s)', energy_text_cfg)
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.p { app.macro_mode = !app.macro_mode}
				.escape {
					app.gg.quit()
				}
				.backspace {
					app.energy = 10

					app.slimes_per_layers = []int{len: 100}
					app.tl = [][]bool{len: 100, init: []bool{len: 100, init: false}}
					app.tr = [][]bool{len: 100, init: []bool{len: 100, init: false}}
					app.bl = [][]bool{len: 100, init: []bool{len: 100, init: true}}
					app.br = [][]bool{len: 100, init: []bool{len: 100, init: true}}

					app.base_click_x = 0
					app.base_click_y = 0
					app.click_x = 0
					app.click_y = 0
					app.block_click_x = 0
					app.block_click_y = 0
					app.mouse_x = 0
					app.mouse_y = 0
					app.clicked = false

					app.viewport_x = 0
					app.viewport_y = 0
				}
				else {}
			}
		}
		.mouse_down {
			match e.mouse_button {
				.left {
					if app.macro_mode {

					}else{
						app.clicked = true
						app.click(e.mouse_x, e.mouse_y)
					}
				}
				else {}
			}
		}
		.mouse_up {
			match e.mouse_button {
				.left {
					if app.macro_mode {
						app.check_macro_valid()
					}else{
						app.clicked = false
						app.move(e.mouse_x, e.mouse_y)
					}
				}
				else {}
			}
		}
		.mouse_scroll {
			if e.scroll_y > 0 {
				app.actual_macro += 1
				if app.actual_macro >= app.macros_moves.len {
					app.actual_macro = app.macros_moves.len-1
				}
			}else{
				app.actual_macro -= 1
				if app.actual_macro < 0 {
					app.actual_macro = 0
				}
			}
		}
		else {}
	}
	app.mouse_x = e.mouse_x
	app.mouse_y = e.mouse_y
}

