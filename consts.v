import gx

const white = gx.white
const gray = gx.Color{229, 236, 236, 255}
const tile_size = 90
const semi_space = 5
const slime_size = tile_size - semi_space*2
const valid_text_cfg = gx.TextCfg{
	color: gx.green
	size: 30
	align: .left
	vertical_align: .top
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
const gray_text_cfg = gx.TextCfg{
	color: gx.gray
	size: 30
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}
const energy_text_cfg = gx.TextCfg{
	color: gx.Color{255, 204, 0, 255}
	size: 45
	align: .left
	vertical_align: .top
	bold: true
	family: 'agency fb'
}
const energy_gain_cfg = gx.TextCfg{
	color: gx.Color{225, 193, 31, 255}
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
const u_logo_cfg = gx.TextCfg{
	color: gx.Color{249, 226, 175, 100}
	size: 620
	align: .center
	vertical_align: .middle
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