/* {{{ ASCII ART
      Z (Blue = Up)
      |
      |
      +-----Y (Yellow = Right)
     /
    X (Red = Front)

Rubics Cube: Red, White, Blue, Orange, Yellow, Green
      5-----------7          5-----------7
     ╱           ╱│         ╱.           │
    ╱     Blue  ╱ │        ╱ .           │
   ╱           ╱  │       ╱  .     Orange│
  6-----------8   │      6   .           │
  │           │ Yellow   │ White         │
  │           │   3      │   1. . . . . .3
  │     Red   │  ╱       │  .           ╱
  │           │ ╱        │ .     Green ╱
  │           │╱         │.           ╱
  2-----------4          2-----------4

  Vertices:
    1: 0 0 0
    2: 1 0 0
    3: 0 1 0
    4: 1 1 0
    5: 0 0 1
    6: 1 0 1
    7: 0 1 1
    8: 1 1 1

  Faces:
    B: 5 6 8 7
    G: 1 3 4 2
    R: 2 4 8 6
    O: 1 5 7 3
    Y: 3 7 8 4
    W: 1 2 6 5


}}} */

package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:math/noise"

VERTEX_COUNTER := 1

main :: proc() {
	w, h := 4, 4
	for j in 0..=h { for i in 0..=w {
		make_02(f64( i), f64( j))
		make_02(f64(-i), f64( j))
		make_02(f64( i), f64(-j))
		make_02(f64(-i), f64(-j))
	}}
}

make_02 :: proc(dx, dy: f64) {
	w, h :: 256, 256
	grid : [h+1][w+1][3]f64

	for j in 0..=h { for i in 0..=w {
		pos : [2]f64 = {f64(i)/f64(w) + dx, f64(j)/f64(h) + dy}
		c := 1 / math.sqrt(pos.x * pos.x + pos.y * pos.y + 1)
		r := fractal_noise(0, pos.x, pos.y) * c * 0.25
		grid[j][i] = {pos.x, pos.y, r}
	} }


	fmt.printf("o Grid %v\n", rand.uint64())
	for j in 0..=h { for i in 0..=w {
		p := grid[j][i]
		fmt.printf("v\t%v\t%v\t%v\n", p.x, p.z, -p.y)
	} }
	for j in 0..<h { for i in 0..<w {
		p1 := (j+0)*(w+1) + i+0 + VERTEX_COUNTER
		p2 := (j+0)*(w+1) + i+1 + VERTEX_COUNTER
		p3 := (j+1)*(w+1) + i+1 + VERTEX_COUNTER
		p4 := (j+1)*(w+1) + i+0 + VERTEX_COUNTER
		fmt.printf("f\t%v\t%v\t%v\t%v\n", p1, p2, p3, p4)
	} }
	VERTEX_COUNTER += (w+1)*(h+1)
}

fractal_noise :: proc(seed: i64, x: f64, y: f64) -> f64 {
	result : f32 = 0
	for i in 0..<8 {
		f := math.pow(2, f64(i))
		a := math.pow(0.5, f32(i))
		result += noise.noise_2d(seed, {x, y} * f) * a
	}
	return f64(result)
}
