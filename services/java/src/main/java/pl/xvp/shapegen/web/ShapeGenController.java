package pl.xvp.shapegen.web;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import pl.xvp.shapegen.core.Shape;
import pl.xvp.shapegen.core.ShapeGenerator;
import pl.xvp.shapegen.core.rand.RandomSourceImpl;

@Controller
public class ShapeGenController {
	@RequestMapping("/shapegentext")
    public String shapegenText(
    	@RequestParam(value="sizex", required=false) Integer sizex,
    	@RequestParam(value="sizey", required=false) Integer sizey,
    	Model model) {
    	
        model.addAttribute("sizex", sizex);
        model.addAttribute("sizey", sizey);
        
        Shape shape = (new ShapeGenerator(new RandomSourceImpl(), sizex.intValue(), sizey.intValue())).generateShape();
        model.addAttribute("shape", ShapeTextRenderer.renderShapeToText(shape));
        
        return "shapegen/shapegentext";
    }
    
	@RequestMapping(value="/generate", method=RequestMethod.GET)
	public @ResponseBody ShapeJSON getShape(
			@RequestParam(value="sizex", required=false) Integer sizex,
			@RequestParam(value="sizey", required=false) Integer sizey) {
		Shape shape = (new ShapeGenerator(new RandomSourceImpl(), sizex.intValue(), sizey.intValue())).generateShape();
		return ShapeJSON.json(shape);
	}
	
	 @RequestMapping(value = "/", method = RequestMethod.GET)
	 public String redirect() {
		 return "redirect:/resources/shapegenajax.html";
	 }
}


