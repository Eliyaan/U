import math as m

fn cout_deplacement(y f64) int {
	return int(m.pow(2, m.abs(y)))
}

fn (app App) energy_produc(layer int, nb_slimes int) f64 {
	return 0.002 * m.pow(2.2, layer) * cap(nb_slimes, layer + 1) / f64(layer + 1)
}

fn cap(nb int, max int) int {
	if nb >= max {
		return max
	}
	return nb
}
