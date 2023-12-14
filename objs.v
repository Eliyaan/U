import gg

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

	viewport_x f64
	viewport_y f64
	win_size   gg.Size

	energy f64 = 10

	slimes_per_layers []int    = []int{len: 100}
	tl                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: false}}
	tr                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: false}}
	bl                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: true}}
	br                [][]bool = [][]bool{len: 100, init: []bool{len: 100, init: true}}
	macros_spaces [][][]int
	actual_macro int
	macros_moves [][]MacroMove
	macro_mode bool
}