module main
import gg
import gx
import math as m

const (
    bg_color     = gx.black
	gray = gx.Color{229, 236, 236, 255}
)


struct App {
mut:
    gg    &gg.Context = unsafe { nil }

	base_click_x f64
	base_click_y f64
	click_x f64
	click_y f64

	viewport_x f64 = 300
	viewport_y f64 = 300
	r bool
	b bool
	tl [][]bool = [][]bool{len:5, init:[]bool{len:10, init:true}}
	tr [][]bool = [][]bool{len:5, init:[]bool{len:10, init:false}}
	bl [][]bool = [][]bool{len:5, init:[]bool{len:10, init:false}}
	br [][]bool = [][]bool{len:5, init:[]bool{len:10, init:true}}
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
		ui_mode: true
    )	

    //lancement du programme/de la fenêtre
    app.gg.run()
}

fn on_frame(mut app App) {
	size := app.gg.window_size()
	app.viewport_x = size.width/2
	app.viewport_y = size.height/2
    //Draw
    app.gg.begin()
	for y, line in app.bl {
		for x, slime in line {
			if slime {
				app.gg.draw_rounded_rect_filled(f32((-x-1)*30+1+app.viewport_x), f32((y+1)*30+1+app.viewport_y), 28, 28, 5, gx.red)
			}
		}
	}
	for y, line in app.br {
		for x, slime in line {
			if slime {
				app.gg.draw_rounded_rect_filled(f32(x*30+1+app.viewport_x), f32((y+1)*30+1+app.viewport_y), 28, 28, 5, gx.green)
			}
		}
	}
	for y, line in app.tr {
		for x, slime in line {
			if slime {
				app.gg.draw_rounded_rect_filled(f32(x*30+1+app.viewport_x), f32(-y*30+1+app.viewport_y), 28, 28, 5, gx.blue)
			}
		}
	}
	for y, line in app.tl {
		for x, slime in line {
			if slime {
				app.gg.draw_rounded_rect_filled(f32((-x-1)*30+1+app.viewport_x), f32(-y*30+1+app.viewport_y), 28, 28, 5, gx.black)
			}
		}
	}
    app.gg.end()
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
					app.click(e.mouse_x, e.mouse_y)
				}
                else{}
        }}
        .mouse_up {
            match e.mouse_button{
                .left{
					app.pos(e.mouse_x, e.mouse_y)
				}
                else{}
        }}
        else {}
    }
}

fn (mut app App) click(x f32, y f32) {
	app.click_x = x
	app.click_y = y
	if m.floor((x-app.viewport_x)/30) >= 0 {
		app.r = true
		if m.floor((y-app.viewport_y)/30-1) >= 0 {
			app.b = true
			app.base_click_x = m.floor((x-app.viewport_x)/30)
			app.base_click_y = m.floor((y-app.viewport_y)/30-1)
		} else {
			app.b = false
			app.base_click_x = m.floor((x-app.viewport_x)/30)
			app.base_click_y = m.floor(-(y-app.viewport_y)/30+1)
		}
	} else {
		app.r = false
		if m.floor((y-app.viewport_y)/30-1) >= 0 {
			app.b = true
			app.base_click_x = m.floor(-(x-app.viewport_x)/30)
			app.base_click_y = m.floor((y-app.viewport_y)/30-1)
		} else {
			app.b = false
			app.base_click_x = m.floor(-(x-app.viewport_x)/30)
			app.base_click_y = m.floor(-(y-app.viewport_y)/30+1)
		}
	}
}

fn (mut app App) pos(x f32, y f32) {
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
	} else if (x - app.click_x) > m.abs(app.click_y - y) { // direction -> right // TODO
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