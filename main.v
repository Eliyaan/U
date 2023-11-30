module main
import gg
import gx
import math as m

/*
TODO:
- lil line when cursor not far enough else: outline the concerned square with green/red depending on if valid or not (if it misses a stacking obj signal it) and a little arrow pointing to the square that is pointed towards
- faire une fonction pour transfo des coos en coo d'arrays bl br tr lr pour tout uniformiser sans les checks répétitifs dcp
- énergie -> recharge -> dépenses
- déplacement cavalier (d'abord mangeage extérieur puis possibilité mangeage intérrieur)
- save
- juice icone énergie qui boing, slimes qui touing, dezoom, zoom
- lvl des slimes (combien ils en ont stack) (changement alpha)
- autre déplacements ?
- voir pour les niveaux requis etc
- macros 
-> taille canva macro
-> position requise 
-> déplacements (basique, cavale cavale ...)
-> save
- débloque 1 nouvelle couleur par ligne
*/

const (
    bg_color     = gx.black
	gray = gx.Color{229, 236, 236, 255}
	tile_size = 90
)


struct App {
mut:
    gg    &gg.Context = unsafe { nil }

	base_click_x f64
	base_click_y f64
	click_x f64
	click_y f64
	block_click_x f64
	block_click_y f64
	mouse_x f64
	mouse_y f64
	clicked bool

	viewport_x f64
	viewport_y f64
	win_size gg.Size

	r bool
	b bool
	tl [][]bool = [][]bool{len:100, init:[]bool{len:100, init:false}}
	tr [][]bool = [][]bool{len:100, init:[]bool{len:100, init:false}}
	bl [][]bool = [][]bool{len:100, init:[]bool{len:100, init:true}}
	br [][]bool = [][]bool{len:100, init:[]bool{len:100, init:true}}
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
        sample_count: 2
		//ui_mode: true
    )	

    //lancement du programme/de la fenêtre
    app.gg.run()
}

fn on_frame(mut app App) {
	app.win_size = app.gg.window_size()
	if app.viewport_x == 0 && app.viewport_y == 0 {
		app.viewport_x = app.win_size.width/2
		app.viewport_y = app.win_size.height/2
	}else{
		if app.mouse_x > app.win_size.width-100 {
			app.viewport_x -= (100 - (app.win_size.width-app.mouse_x))/10.0
		}
		if app.mouse_x < 100 {
			app.viewport_x += (100 - (app.mouse_x))/10.0
		}
		if app.mouse_y > app.win_size.height-100 {
			app.viewport_y -= (100 - (app.win_size.height-app.mouse_y))/10.0
		}
		if app.mouse_y < 100 {
			app.viewport_y += (100 - (app.mouse_y))/10.0
		}
	}
    //Draw
    app.gg.begin()
	app.draw_slimes()
	app.highlights()
    app.gg.end()
}

fn (mut app App) draw_slimes() {
	for y, line in app.bl {
		y_pos := f32((y+1)*tile_size+1+app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32((-x-1)*tile_size+1+app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size-2, tile_size-2, 5, gx.red)
					}
				}
			}
		}
	}
	for y, line in app.br {
		y_pos := f32((y+1)*tile_size+1+app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32(x*tile_size+1+app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size-2, tile_size-2, 5, gx.red)
					}
				}
			}
		}
	}
	for y, line in app.tr {
		y_pos := f32(-y*tile_size+1+app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32(x*tile_size+1+app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size-2, tile_size-2, 5, gx.red)
					}
				}
			}
		}
	}
	for y, line in app.tl {
		y_pos := f32(-y*tile_size+1+app.viewport_y)
		if y_pos >= -tile_size && y_pos < app.win_size.height {
			for x, slime in line {
				if slime {
					x_pos := f32((-x-1)*tile_size+1+app.viewport_x)
					if x_pos >= -tile_size && x_pos < app.win_size.width {
						app.gg.draw_rounded_rect_filled(x_pos, y_pos, tile_size-2, tile_size-2, 5, gx.red)
					}
				}
			}
		}
	}
}

fn on_event(e &gg.Event, mut app App){
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.gg.quit()}
                else {}
            }
        }
		.mouse_down {
            match e.mouse_button{
                .left{
					app.clicked = true
					app.click(e.mouse_x, e.mouse_y)
				}
                else{}
        	}
		}
        .mouse_up {
            match e.mouse_button{
                .left{
					app.clicked = false
					app.pos(e.mouse_x, e.mouse_y)
				}
                else{}
        	}
		}
        else {}
    }
	app.mouse_x = e.mouse_x
	app.mouse_y = e.mouse_y
}

fn (mut app App) click(x f32, y f32) {
	app.click_x = x
	app.click_y = y
	app.block_click_x, app.block_click_y = app.mouse_coord_to_block_coord()
	if m.floor((x-app.viewport_x)/tile_size) >= 0 {
		app.r = true
		if m.floor((y-app.viewport_y)/tile_size-1) >= 0 {
			app.b = true
			app.base_click_x = m.floor((x-app.viewport_x)/tile_size)
			app.base_click_y = m.floor((y-app.viewport_y)/tile_size-1)
		} else {
			app.b = false
			app.base_click_x = m.floor((x-app.viewport_x)/tile_size)
			app.base_click_y = m.floor(-(y-app.viewport_y)/tile_size+1)
		}
	} else {
		app.r = false
		if m.floor((y-app.viewport_y)/tile_size-1) >= 0 {
			app.b = true
			app.base_click_x = m.floor(-(x-app.viewport_x)/tile_size)
			app.base_click_y = m.floor((y-app.viewport_y)/tile_size-1)
		} else {
			app.b = false
			app.base_click_x = m.floor(-(x-app.viewport_x)/tile_size)
			app.base_click_y = m.floor(-(y-app.viewport_y)/tile_size+1)
		}
	}
}

fn (mut app App) highlights() {
	if app.clicked {
		// Start block
		start_coo_x := f32(app.block_click_x*tile_size+tile_size*0.5+app.viewport_x)
		start_coo_y := f32(app.block_click_y*tile_size+tile_size*0.5+app.viewport_y)
		// End block
		mut end_block_x, mut end_block_y := app.block_click_x, app.block_click_y //app.mouse_coord_to_block_coord()
		
		if (app.click_x - app.mouse_x)*(app.click_x - app.mouse_x) + (app.click_y - app.mouse_y)*(app.click_y - app.mouse_y) > tile_size*tile_size {
			if (app.click_y - app.mouse_y) > m.abs(app.click_x - app.mouse_x) { // direction -> up
				end_block_y -= 2
			} else if (app.mouse_y - app.click_y) > m.abs(app.click_x - app.mouse_x) { // direction -> down
				end_block_y += 2
			} else if (app.click_x - app.mouse_x) > m.abs(app.click_y - app.mouse_y) { // direction -> left
				end_block_x -= 2
			} else if (app.mouse_x - app.click_x) > m.abs(app.click_y - app.mouse_y) { // direction -> right
				end_block_x += 2
			}
			end_x := f32(end_block_x*tile_size+tile_size*0.5+app.viewport_x)
			end_y := f32(end_block_y*tile_size+tile_size*0.5+app.viewport_y)
			app.gg.draw_line_with_config(end_x, end_y, start_coo_x, start_coo_y, gg.PenConfig {gx.Color{0, 255, 0, 255}, .solid, 10})
		}
	}
}

fn (mut app App) mouse_coord_to_block_coord() (f64, f64) {
	return m.floor((app.mouse_x - app.viewport_x)/tile_size), m.floor((app.mouse_y - app.viewport_y)/tile_size)
}

fn (mut app App) pos(x f32, y f32) {
	if (app.click_x - x)*(app.click_x - x) + (app.click_y - y)*(app.click_y - y) > tile_size*tile_size {
		if (app.click_y - y) > m.abs(app.click_x - x) { // direction -> up
			if app.r { // right
				if app.b {
					if app.br.len > int(app.base_click_y) && app.br[int(app.base_click_y)].len > int(app.base_click_x) { // check de pas avoir le click en dehors de l'array 
						if int(app.base_click_y) - 2 >= 0 {
							if !app.br[int(app.base_click_y)-2][int(app.base_click_x)] && app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)-1][int(app.base_click_x)] {
								app.br[int(app.base_click_y)][int(app.base_click_x)] = false
								app.br[int(app.base_click_y)-1][int(app.base_click_x)] = false
								app.br[int(app.base_click_y)-2][int(app.base_click_x)] = true
							}
						}else{
							if int(app.base_click_y) - 1 >= 0 {
								if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)-1][int(app.base_click_x)] && !app.tr[0][int(app.base_click_x)] {
									app.br[int(app.base_click_y)][int(app.base_click_x)] = false
									app.br[int(app.base_click_y)-1][int(app.base_click_x)] = false
									app.tr[0][int(app.base_click_x)] = true 
								}
							} else {
								if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.tr[0][int(app.base_click_x)] && !app.tr[1][int(app.base_click_x)] {
									app.br[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tr[0][int(app.base_click_x)] = false
									app.tr[1][int(app.base_click_x)] = true 
								}
							}

						}
					}
				} else {
					if app.tr.len > int(app.base_click_y) + 2 && app.tr[int(app.base_click_y)].len > int(app.base_click_x) {
						if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)+1][int(app.base_click_x)] && !app.tr[int(app.base_click_y)+2][int(app.base_click_x)] {
							app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
							app.tr[int(app.base_click_y)+1][int(app.base_click_x)] = false
							app.tr[int(app.base_click_y)+2][int(app.base_click_x)] = true
						}
					}
				}
			} else { // left side
				if app.b {
					if app.bl.len > int(app.base_click_y) && app.bl[int(app.base_click_y)].len > int(app.base_click_x) {
						if int(app.base_click_y) - 2 >= 0 {
							if !app.bl[int(app.base_click_y)-2][int(app.base_click_x)] && app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)-1][int(app.base_click_x)] {
								app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
								app.bl[int(app.base_click_y)-1][int(app.base_click_x)] = false
								app.bl[int(app.base_click_y)-2][int(app.base_click_x)] = true
							}
						}else{
							if int(app.base_click_y) - 1 >= 0 {
								if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)-1][int(app.base_click_x)] && !app.tl[0][int(app.base_click_x)] {
									app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.bl[int(app.base_click_y)-1][int(app.base_click_x)] = false
									app.tl[0][int(app.base_click_x)] = true 
								}
							} else {
								if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[0][int(app.base_click_x)] && !app.tl[1][int(app.base_click_x)] {
									app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tl[0][int(app.base_click_x)] = false
									app.tl[1][int(app.base_click_x)] = true 
								}
							}
						}
					}
				} else {
					if app.tl.len > int(app.base_click_y) + 2 && app.tl[int(app.base_click_y)].len > int(app.base_click_x) {
						if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)+1][int(app.base_click_x)] && !app.tl[int(app.base_click_y)+2][int(app.base_click_x)] {
							app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
							app.tl[int(app.base_click_y)+1][int(app.base_click_x)] = false
							app.tl[int(app.base_click_y)+2][int(app.base_click_x)] = true
						}
					}
				}
			}
		} else if (y - app.click_y) > m.abs(app.click_x - x) { // direction -> down
			if app.r { // right
				if !app.b {
					if app.tr.len > int(app.base_click_y) && app.tr[int(app.base_click_y)].len > int(app.base_click_x) { // check de pas avoir le click en dehors de l'array 
						if int(app.base_click_y) - 2 >= 0 {
							if !app.tr[int(app.base_click_y)-2][int(app.base_click_x)] && app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)-1][int(app.base_click_x)] {
								app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
								app.tr[int(app.base_click_y)-1][int(app.base_click_x)] = false
								app.tr[int(app.base_click_y)-2][int(app.base_click_x)] = true
							}
						}else{
							if int(app.base_click_y) - 1 >= 0 {
								if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)-1][int(app.base_click_x)] && !app.br[0][int(app.base_click_x)] {
									app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tr[int(app.base_click_y)-1][int(app.base_click_x)] = false
									app.br[0][int(app.base_click_x)] = true 
								}
							} else {
								if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.br[0][int(app.base_click_x)] && !app.br[1][int(app.base_click_x)] {
									app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
									app.br[0][int(app.base_click_x)] = false
									app.br[1][int(app.base_click_x)] = true 
								}
							}

						}
					}
				} else {
					if app.br.len > int(app.base_click_y) + 2 && app.br[int(app.base_click_y)].len > int(app.base_click_x) {
						if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)+1][int(app.base_click_x)] && !app.br[int(app.base_click_y)+2][int(app.base_click_x)] {
							app.br[int(app.base_click_y)][int(app.base_click_x)] = false
							app.br[int(app.base_click_y)+1][int(app.base_click_x)] = false
							app.br[int(app.base_click_y)+2][int(app.base_click_x)] = true
						}
					}
				}
			} else { // left side
				if !app.b {
					if app.tl.len > int(app.base_click_y) && app.tl[int(app.base_click_y)].len > int(app.base_click_x) {
						if int(app.base_click_y) - 2 >= 0 {
							if !app.tl[int(app.base_click_y)-2][int(app.base_click_x)] && app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)-1][int(app.base_click_x)] {
								app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
								app.tl[int(app.base_click_y)-1][int(app.base_click_x)] = false
								app.tl[int(app.base_click_y)-2][int(app.base_click_x)] = true
							}
						}else{
							if int(app.base_click_y) - 1 >= 0 {
								if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)-1][int(app.base_click_x)] && !app.bl[0][int(app.base_click_x)] {
									app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tl[int(app.base_click_y)-1][int(app.base_click_x)] = false
									app.bl[0][int(app.base_click_x)] = true 
								}
							} else {
								if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[0][int(app.base_click_x)] && !app.bl[1][int(app.base_click_x)] {
									app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.bl[0][int(app.base_click_x)] = false
									app.bl[1][int(app.base_click_x)] = true 
								}
							}
						}
					}
				} else {
					if app.bl.len > int(app.base_click_y)+2 && app.bl[int(app.base_click_y)].len > int(app.base_click_x) {
						if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)+1][int(app.base_click_x)] && !app.bl[int(app.base_click_y)+2][int(app.base_click_x)] {
							app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
							app.bl[int(app.base_click_y)+1][int(app.base_click_x)] = false
							app.bl[int(app.base_click_y)+2][int(app.base_click_x)] = true
						}
					}
				}
			}
		} else if (app.click_x - x) > m.abs(app.click_y - y) { // direction -> left
			if app.r {
				if app.b {
					if app.br.len > int(app.base_click_y) && app.br[int(app.base_click_y)].len > int(app.base_click_x) { // check de pas avoir le click en dehors de l'array 
						if int(app.base_click_x) - 2 >= 0 {
							if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)][int(app.base_click_x)-1] && !app.br[int(app.base_click_y)][int(app.base_click_x)-2]{
								app.br[int(app.base_click_y)][int(app.base_click_x)] = false
								app.br[int(app.base_click_y)][int(app.base_click_x)-1] = false
								app.br[int(app.base_click_y)][int(app.base_click_x)-2] = true
							}
						}else{
							if int(app.base_click_x) - 1 >= 0 {
								if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)][int(app.base_click_x)-1] && !app.bl[int(app.base_click_y)][0] {
									app.br[int(app.base_click_y)][int(app.base_click_x)] = false
									app.br[int(app.base_click_y)][int(app.base_click_x)-1] = false
									app.bl[int(app.base_click_y)][0] = true 
								}
							} else {
								if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)][0] && !app.bl[int(app.base_click_y)][1] {
									app.br[int(app.base_click_y)][int(app.base_click_x)] = false
									app.bl[int(app.base_click_y)][0] = false
									app.bl[int(app.base_click_y)][1] = true 
								}
							}

						}
					}
				} else {
					if app.tr.len > int(app.base_click_y) && app.tr[int(app.base_click_y)].len > int(app.base_click_x) {
						if int(app.base_click_x) - 2 >= 0 {
							if !app.tr[int(app.base_click_y)][int(app.base_click_x)-2] && app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)][int(app.base_click_x)-1] {
								app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
								app.tr[int(app.base_click_y)][int(app.base_click_x)-1] = false
								app.tr[int(app.base_click_y)][int(app.base_click_x)-2] = true
							}
						}else{
							if int(app.base_click_x) - 1 >= 0 {
								if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)][int(app.base_click_x)-1] && !app.tl[int(app.base_click_y)][0] {
									app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tr[int(app.base_click_y)][int(app.base_click_x)-1] = false
									app.tl[int(app.base_click_y)][0] = true 
								}
							} else {
								if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)][0] && !app.tl[int(app.base_click_y)][1] {
									app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tl[int(app.base_click_y)][0] = false
									app.tl[int(app.base_click_y)][1] = true 
								}
							}

						}
					}
				}
			} else { // left side
				if app.b {
					if app.bl.len > int(app.base_click_y) && app.bl[int(app.base_click_y)].len > int(app.base_click_x) + 2 {
						if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)][int(app.base_click_x)+1] && !app.bl[int(app.base_click_y)][int(app.base_click_x)+2] {
							app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
							app.bl[int(app.base_click_y)][int(app.base_click_x)+1] = false
							app.bl[int(app.base_click_y)][int(app.base_click_x)+2] = true
						}
					}
				} else {
					if app.tl.len > int(app.base_click_y) && app.tl[int(app.base_click_y)].len > int(app.base_click_x) + 2 {
						if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)][int(app.base_click_x)+1] && !app.tl[int(app.base_click_y)][int(app.base_click_x)+2] {
							app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
							app.tl[int(app.base_click_y)][int(app.base_click_x)+1] = false
							app.tl[int(app.base_click_y)][int(app.base_click_x)+2] = true
						}
					}
				}
			}
		} else if (x - app.click_x) > m.abs(app.click_y - y) { // direction -> right
			if app.r { // right
				if app.b {
					if app.br.len > int(app.base_click_y) && app.br[int(app.base_click_y)].len > int(app.base_click_x) + 2 { // check de pas avoir le click en dehors de l'array 
						if app.br[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)][int(app.base_click_x)+1] && !app.br[int(app.base_click_y)][int(app.base_click_x)+2] {
							app.br[int(app.base_click_y)][int(app.base_click_x)] = false
							app.br[int(app.base_click_y)][int(app.base_click_x)+1] = false
							app.br[int(app.base_click_y)][int(app.base_click_x)+2] = true
						}
					}
				} else {
					if app.tr.len > int(app.base_click_y) && app.tr[int(app.base_click_y)].len > int(app.base_click_x) + 2 { // check de pas avoir le click en dehors de l'array 
						if app.tr[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)][int(app.base_click_x)+1] && !app.tr[int(app.base_click_y)][int(app.base_click_x)+2] {
							app.tr[int(app.base_click_y)][int(app.base_click_x)] = false
							app.tr[int(app.base_click_y)][int(app.base_click_x)+1] = false
							app.tr[int(app.base_click_y)][int(app.base_click_x)+2] = true
						}
					}
				}
			} else { // left side
				if !app.b {
					if app.tl.len > int(app.base_click_y) && app.tl[int(app.base_click_y)].len > int(app.base_click_x) {
						if int(app.base_click_x) - 2 >= 0 {
							if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)][int(app.base_click_x)-1] && !app.tl[int(app.base_click_y)][int(app.base_click_x)-2]{
								app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
								app.tl[int(app.base_click_y)][int(app.base_click_x)-1] = false
								app.tl[int(app.base_click_y)][int(app.base_click_x)-2] = true
							}
						}else{
							if int(app.base_click_x) - 1 >= 0 {
								if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tl[int(app.base_click_y)][int(app.base_click_x)-1] && !app.tr[int(app.base_click_y)][0] {
									app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tl[int(app.base_click_y)][int(app.base_click_x)-1] = false
									app.tr[int(app.base_click_y)][0] = true 
								}
							} else {
								if app.tl[int(app.base_click_y)][int(app.base_click_x)] && app.tr[int(app.base_click_y)][0] && !app.tr[int(app.base_click_y)][1] {
									app.tl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.tr[int(app.base_click_y)][0] = false
									app.tr[int(app.base_click_y)][1] = true 
								}
							}

						}
					}
				} else {
					if app.bl.len > int(app.base_click_y) && app.bl[int(app.base_click_y)].len > int(app.base_click_x) {
						if int(app.base_click_x) - 2 >= 0 {
							if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)][int(app.base_click_x)-1] && !app.bl[int(app.base_click_y)][int(app.base_click_x)-2]{
								app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
								app.bl[int(app.base_click_y)][int(app.base_click_x)-1] = false
								app.bl[int(app.base_click_y)][int(app.base_click_x)-2] = true
							}
						}else{
							if int(app.base_click_x) - 1 >= 0 {
								if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.bl[int(app.base_click_y)][int(app.base_click_x)-1] && !app.br[int(app.base_click_y)][0] {
									app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.bl[int(app.base_click_y)][int(app.base_click_x)-1] = false
									app.br[int(app.base_click_y)][0] = true 
								}
							} else {
								if app.bl[int(app.base_click_y)][int(app.base_click_x)] && app.br[int(app.base_click_y)][0] && !app.br[int(app.base_click_y)][1] {
									app.bl[int(app.base_click_y)][int(app.base_click_x)] = false
									app.br[int(app.base_click_y)][0] = false
									app.br[int(app.base_click_y)][1] = true 
								}
							}
						}
					}
				}
			}
		}
	}
}