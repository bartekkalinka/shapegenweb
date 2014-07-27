package pl.xvp.shapegen.core;

public class Shape {
	public int sizex;
	public int sizey;
	public boolean shape[][];
	
	public Shape(int sizex, int sizey) {
		this.sizex = sizex;
		this.sizey = sizey;
	}
	
	public Shape(int sizex, int sizey, boolean shape[][]) {
		this.sizex = sizex;
		this.sizey = sizey;
		this.shape = shape;
	}
	
	
	public int getWeight() {
		int ret = 0;
		
		for(int x=0; x<sizex; x++) {
			for(int y=0; y<sizey; y++) {
				if(shape[x][y]) ret++;
			}
		}
		
		return ret;
	}

}

