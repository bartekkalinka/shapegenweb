package pl.xvp.shapegen.web;

import java.util.List;

import pl.xvp.shapegen.core.Shape;

public final class ShapeJSON {
	public int getSizex() {
		return sizex;
	}

	public int getSizey() {
		return sizey;
	}
	
	public List<String> getRows() {
		return rows;
	}
	
	public boolean[][] getShape() {
		return shape;
	}
	
	public static ShapeJSON json(Shape shape) {
		return new ShapeJSON(shape.sizex, shape.sizey, 
					ShapeTextRenderer.renderShapeToText(shape),
					shape.shape);
	}
	
	// internal
	
	private int sizex;
	private int sizey;
	private List<String> rows;
	private boolean[][] shape;
	
	private ShapeJSON(int sizex, int sizey, List<String> rows, boolean[][] shape) {
		this.sizex = sizex;
		this.sizey = sizey;
		this.rows = rows;
		this.shape = shape;
	}
}
