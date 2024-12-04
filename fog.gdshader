shader_type canvas_item;
uniform float opacity : hint_range(0.0, 1.0) = 0.5;

void vertex() {

}

void fragment() {
	COLOR.a = opacity;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
