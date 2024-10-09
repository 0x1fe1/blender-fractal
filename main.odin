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
import "core:strings"

VERTICES := [dynamic]Vertex{}
VERTEX_COUNT := 0

Vertex :: [3]f32
Cube :: [8]Vertex
CubeExt :: struct {
	cube: Cube,
	from: Direction,
}

// {{{ TYPES
Direction :: enum {
	None,	// 0
	Red,	// X+
	Orange,	// X-
	Yellow,	// Y+
	White,	// Y-
	Blue,	// Z+
	Green,	// Z-
}

DirectionV :: [Direction]Vertex{
	.None	= { 0,  0,  0},
	.Red	= { 1,  0,  0},
	.Orange	= {-1,  0,  0},
	.Yellow	= { 0,  1,  0},
	.White	= { 0, -1,  0},
	.Blue	= { 0,  0,  1},
	.Green	= { 0,  0, -1},
}

CubeV :: Cube {
	{0, 0, 0},
	{1, 0, 0},
	{0, 1, 0},
	{1, 1, 0},
	{0, 0, 1},
	{1, 0, 1},
	{0, 1, 1},
	{1, 1, 1},
}

CubeF :: [Direction][4]int{
	.None	= {0, 0, 0, 0},
	.Red	= {2, 4, 8, 6}, // R
	.Orange	= {1, 5, 7, 3}, // O
	.Yellow	= {3, 7, 8, 4}, // Y
	.White	= {1, 2, 6, 5}, // W
	.Blue	= {5, 6, 8, 7}, // B
	.Green	= {1, 3, 4, 2}, // G
}
// }}}

main :: proc() {
	fmt.println("o Custom")
	make_fractal_01a()
}

make_fractal_01a :: proc() {
	cubes_free : [dynamic]CubeExt = { {CubeV-0.5, .None} }
	cubes_extended : [dynamic]CubeExt
	factor : f32 = f32(1)/f32(3)

	extend :: proc(cube: CubeExt, dir: Direction, factor: f32) -> CubeExt {
		directions := DirectionV

		new_cube := scale_cube_ext(cube, factor)
		l1 := cube_len_ext(cube)
		l2 := cube_len_ext(new_cube)

		for i in 0..<8 {
			new_cube.cube[i] += directions[dir] * (l1+l2)/2
		}

		new_cube.from = dir
		return new_cube
	}

	loop_count := 1 // + 6 + 6*5 + 6*5*5 // + 6*5*5*5 + 6*5*5*5*5 + 6*5*5*5*5*5
	for loop := 0; loop < loop_count && len(cubes_free) > 0; loop += 1 {
		c, ok := pop_front_safe(&cubes_free)
		if !ok { break }

		for dir, i in Direction {
			if dir == .None ||
			c.from == .Red		&& dir == .Orange ||
			c.from == .Orange	&& dir == .Red ||
			c.from == .Yellow	&& dir == .White ||
			c.from == .White	&& dir == .Yellow ||
			c.from == .Blue		&& dir == .Green ||
			c.from == .Green	&& dir == .Blue {
				continue
			}

			new_c := extend(c, dir, factor)
			append(&cubes_free, new_c)
		}
		append(&cubes_extended, c)
	}

	for c in cubes_extended {
		fmt.println(render_cube_ext_1(c, factor))
	}
	for c in cubes_free {
		fmt.println(render_cube_ext(c))
	}
}

// {{{
make_fractal_01 :: proc() {
	cubes_free : [dynamic]CubeExt = { {CubeV-0.5, .None} }
	cubes_extended : [dynamic]CubeExt

	extend :: proc(cube: CubeExt, dir: Direction) -> CubeExt {
		factor : f32 = 0.5
		directions := DirectionV

		new_cube := scale_cube_ext(cube, factor)
		l1 := cube_len_ext(cube)
		l2 := cube_len_ext(new_cube)

		for i in 0..<8 {
			new_cube.cube[i] += directions[dir] * (l1+l2)/2
		}

		new_cube.from = dir
		return new_cube
	}

	loop_count := 1 + 6*5 + 6*5*5 + 6*5*5*5 + 6*5*5*5*5 + 6*5*5*5*5*5
	for loop := 0; loop < loop_count && len(cubes_free) > 0; loop += 1 {
		c, ok := pop_front_safe(&cubes_free)
		if !ok { break }

		for dir, i in Direction {
			if dir == .None ||
			c.from == .Red		&& dir == .Orange ||
			c.from == .Orange	&& dir == .Red ||
			c.from == .Yellow	&& dir == .White ||
			c.from == .White	&& dir == .Yellow ||
			c.from == .Blue		&& dir == .Green ||
			c.from == .Green	&& dir == .Blue {
				continue
			}

			new_c := extend(c, dir)
			append(&cubes_free, new_c)
		}
		append(&cubes_extended, c)
	}

	for c in cubes_extended {
		fmt.println(render_cube_ext(c))
	}
	for c in cubes_free {
		fmt.println(render_cube_ext(c))
	}
}
// }}}

// {{{ HELPERS
cube_len :: proc(cube: Cube) -> f32 {
	return cube[1][0] - cube[0][0]
}
cube_len_ext :: proc(cube: CubeExt) -> f32 {
	return cube_len(cube.cube)
}

scale_cube :: proc(cube: Cube, factor: f32) -> Cube {
	new_cube := cube
	l := cube_len(cube)
	origin := cube[0]
	for i in 0..<8 {
		new_cube[i] -= origin + l/2
	}
	new_cube *= factor
	for i in 0..<8 {
		new_cube[i] += origin + l/2
	}
	return new_cube
}
scale_cube_ext :: proc(cube: CubeExt, factor: f32) -> CubeExt {
	return { scale_cube(cube.cube, factor), cube.from }
}
// }}}

// {{{ RENDER
render_cube :: proc(cube: Cube) -> string {
	result : [dynamic]string
	defer delete(result)

	for v in cube {
		append(&result, fmt.tprintf("v %v %v %v\n", v[0], v[2], -v[1]))
	}

	faces := CubeF
	for dir in Direction {
		f := faces[dir] + VERTEX_COUNT
		append(&result, fmt.tprintf("f %v %v %v %v\n", f[0], f[1], f[2], f[3]))
	}

	VERTEX_COUNT += 8

	res, err := strings.concatenate(result[:])
	return res
}
// }}}

render_cube_ext :: proc(cube: CubeExt) -> string {
	result : [dynamic]string
	defer delete(result)

	for v in cube.cube {
		append(&result, fmt.tprintf("v %v %v %v\n", v[0], v[2], -v[1]))
		append(&VERTICES, v)
	}

	faces := CubeF
	for dir in Direction {
		if dir == .None ||
		cube.from == .Red	&& dir == .Orange ||
		cube.from == .Orange	&& dir == .Red ||
		cube.from == .Yellow	&& dir == .White ||
		cube.from == .White	&& dir == .Yellow ||
		cube.from == .Blue	&& dir == .Green ||
		cube.from == .Green	&& dir == .Blue { continue }
		f := faces[dir] + len(VERTICES)-8
		append(&result, fmt.tprintf("f %v %v %v %v\n", f[0], f[1], f[2], f[3]))
	}

	res, err := strings.concatenate(result[:])
	return res
}

render_cube_ext_1 :: proc(cube: CubeExt, factor: f32) -> string {
	result : [dynamic]string
	defer delete(result)

	for v in cube.cube {
		append(&result, fmt.tprintf("v %v %v %v\n", v[0], v[2], -v[1]))
		append(&VERTICES, v)
	}

	faces := CubeF
	for dir in Direction {
		if dir == .None ||
		cube.from == .Red	&& dir == .Orange ||
		cube.from == .Orange	&& dir == .Red ||
		cube.from == .Yellow	&& dir == .White ||
		cube.from == .White	&& dir == .Yellow ||
		cube.from == .Blue	&& dir == .Green ||
		cube.from == .Green	&& dir == .Blue { continue }

		// fmt.eprintln(dir, faces[dir], factor)
		// fmt.eprintln(cube)
		// fmt.eprintln(VERTICES)

		f := faces[dir] + len(VERTICES)-8

		v0 := VERTICES[f[0]-1]
		v1 := VERTICES[f[1]-1]
		v2 := VERTICES[f[2]-1]
		v3 := VERTICES[f[3]-1]
		v0c := v0 + (v2-v0)/2 * (1-factor)
		v1c := v1 + (v3-v1)/2 * (1-factor)
		v2c := v2 + (v0-v2)/2 * (1-factor)
		v3c := v3 + (v1-v3)/2 * (1-factor)
		append(&VERTICES, v0c)
		append(&VERTICES, v1c)
		append(&VERTICES, v2c)
		append(&VERTICES, v3c)
		append(&result, fmt.tprintf("v %v %v %v\n", v0c[0], v0c[2], -v0c[1]))
		append(&result, fmt.tprintf("v %v %v %v\n", v1c[0], v1c[2], -v1c[1]))
		append(&result, fmt.tprintf("v %v %v %v\n", v2c[0], v2c[2], -v2c[1]))
		append(&result, fmt.tprintf("v %v %v %v\n", v3c[0], v3c[2], -v3c[1]))
	}
	for dir in Direction {
		if dir == .None ||
		cube.from == .Red	&& dir == .Orange ||
		cube.from == .Orange	&& dir == .Red ||
		cube.from == .Yellow	&& dir == .White ||
		cube.from == .White	&& dir == .Yellow ||
		cube.from == .Blue	&& dir == .Green ||
		cube.from == .Green	&& dir == .Blue { continue }

		// fmt.eprintln(dir, faces[dir], factor)
		// fmt.eprintln(cube)
		// fmt.eprintln(VERTICES)

		f := faces[dir] + len(VERTICES)-8-6*4

		f0c := len(VERTICES)+0
		f1c := len(VERTICES)+1
		f2c := len(VERTICES)+2
		f3c := len(VERTICES)+3
		append(&result, fmt.tprintf("f %v %v %v %v %v\n",
				f[0], f[1], f[2], f[3], f[0]))//, f0c, f3c, f2c, f1c, f0c))

		// append(&result, fmt.tprintf("f %v %v %v %v\n", f[0], f[1], f[2], f[3]))
	}

	res, err := strings.concatenate(result[:])
	return res
}
