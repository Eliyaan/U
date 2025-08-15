import gg

const white = gg.white
const gray = gg.Color{229, 236, 236, 255}
const tile_size = 90
const semi_space = 5
const slime_size = tile_size - semi_space*2
const valid_text_cfg = gg.TextCfg{
	color: gg.green
	size: 30
	align: .left
	vertical_align: .top
	bold: true
}
const valid_macro_cfg = gg.TextCfg{
	color: gg.green
	size: 30
	align: .center
	vertical_align: .middle
	bold: true
}
const notvalid_macro_cfg = gg.TextCfg{
	color: gg.red
	size: 30
	align: .center
	vertical_align: .middle
	bold: true
}
const gray_text_cfg = gg.TextCfg{
	color: gg.gray
	size: 30
	align: .left
	vertical_align: .top
	bold: true
}
const energy_text_cfg = gg.TextCfg{
	color: gg.Color{255, 204, 0, 255}
	size: 45
	align: .left
	vertical_align: .top
	bold: true
}
const energy_gain_cfg = gg.TextCfg{
	color: gg.Color{225, 193, 31, 255}
	size: 30
	align: .left
	vertical_align: .top
	bold: true
}
const invalid_text_cfg = gg.TextCfg{
	color: gg.red
	size: 30
	align: .left
	vertical_align: .top
	bold: true
}
const u_logo_cfg = gg.TextCfg{
	color: gg.Color{249, 226, 175, 100}
	size: 620
	align: .center
	vertical_align: .middle
	bold: true
}
const macro_mode_cfg = gg.TextCfg{
	color: gg.Color{0, 198, 68, 200}
	size: 40
	align: .center
	vertical_align: .middle
	bold: true
}
