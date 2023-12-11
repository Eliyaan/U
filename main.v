module main

import gg
import gx
import math as m

/*
TODO:
- déplacement cavalier intérrieur
- save
- Juice icone énergie qui boing, slimes qui touing, dezoom, zoom (image draw call)
- autre déplacements ?
- voir pour les niveaux requis etc
- macros
-> taille canva macro
-> position requise
-> déplacements (basique, cavale cavale ...)
-> save
- lvl des slimes (combien ils en ont stack) (changement alpha)
- débloque 1 nouvelle couleur par ligne
*/

const white = gx.white
const gray = gx.Color{229, 236, 236, 255}
const tile_size = 90
const tile_color = gx.Color{128, 128, 128, 255}
const valid_text_cfg = gx.TextCfg{
	color: gx.green
	size: 30
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}
const energy_text_cfg = gx.TextCfg{
	color: gx.orange
	size: 30
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}
const invalid_text_cfg = gx.TextCfg{
	color: gx.red
	size: 30
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}

enum ArrayType {
	tl
	tr
	bl
	br
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

	viewport_x f64
	viewport_y f64
	win_size   gg.Size

	energy f64 = 10

	slimes_per_layers []int    = []int{len: 100}
	tl                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: false}}
	tr                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: false}}
	bl                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: true}}
	br                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: true}}
}

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

	// lancement du programme/de la fenêtre
	app.gg.run()
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
	app.draw_slimes()
	app.highlights()
	mut total_new_ener := 0.0
	for i, nb_slimes in app.slimes_per_layers {
		if nb_slimes > 0 {
			new_ener := app.energy_produc(i, nb_slimes)
			app.energy += new_ener
			total_new_ener += new_ener
			app.gg.draw_text(10, int((-i) * tile_size + 1 + app.viewport_y), '${m.round_sig(new_ener * 60,
				2)}/s  (${nb_slimes} / ${i + 1})', energy_text_cfg)
		}
	}
	app.gg.draw_text(0, 0, '${m.round_sig(app.energy, 1)} (+ ${m.round_sig(total_new_ener * 60,
		1)}/s)', energy_text_cfg)
	app.gg.end()
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
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
					app.clicked = true
					app.click(e.mouse_x, e.mouse_y)
				}
				else {}
			}
		}
		.mouse_up {
			match e.mouse_button {
				.left {
					app.clicked = false
					app.move(e.mouse_x, e.mouse_y)
				}
				else {}
			}
		}
		else {}
	}
	app.mouse_x = e.mouse_x
	app.mouse_y = e.mouse_y
}
