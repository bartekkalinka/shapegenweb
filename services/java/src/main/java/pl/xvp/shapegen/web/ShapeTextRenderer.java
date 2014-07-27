package pl.xvp.shapegen.web;

import java.util.ArrayList;
import java.util.List;

import pl.xvp.shapegen.core.Shape;

public class ShapeTextRenderer {
    public static List<String> renderShapeToText(Shape shape) {
        List<String> shapeDisplay = new ArrayList<String>();
        for(int i = 0; i < shape.sizey; i++) {
        	String row = "";
        	for(int j = 0; j < shape.sizex; j++) {
       			row+=((shape.shape[j][i])?"O":".");
        	}
        	shapeDisplay.add(row);
        }
        return shapeDisplay;
    }
}
