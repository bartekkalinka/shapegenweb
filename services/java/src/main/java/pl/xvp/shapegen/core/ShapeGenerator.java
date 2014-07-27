package pl.xvp.shapegen.core;

import java.util.ArrayList;
import java.util.List;

import pl.xvp.shapegen.core.rand.RandomSource;

public class ShapeGenerator {
	private Shape s;
	private RandomSource randsrc;
	
	public ShapeGenerator(RandomSource randsrc, int sizex, int sizey) {
		this.randsrc = randsrc;
		s = new Shape(sizex, sizey);
	}
	
	public Shape generateShape() {
		do {
			generateRandomShape();
		} while (failBeautyStats());
		return s;
	}
	
	private void generateRandomShape() {
		s.shape = new boolean[s.sizex][s.sizey];
		int [][] noise = getSmoothNoiseTable(scaleNoiseTable(getNoiseTable()));
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				s.shape[x][y] = (noise[x][y] >= 500);
			}
		}
		
		s.shape = cutOffLooseFragments(s.shape);
	}
	
	private int[][] getNoiseTable() {
		int [][] ret = new int[s.sizex][s.sizey];
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				ret[x][y] = randsrc.getRand(1000);
			}
		}
		
		return ret;
	}
	
	private void safeNoiseSet(int[][] noise, int x, int y, int value) {
		if(x>=0 && y>=0 && x<s.sizex && y<s.sizey) {
			noise[x][y] = value;
		}
	}
	
	private int safeNoiseGet(int[][] noise, int x, int y) {
		if(x>=0 && y>=0 && x<s.sizex && y<s.sizey) {
			return noise[x][y];
		}
		else {
			return 0;
		}
	}	
	
	private int[][] scaleNoiseTable(int[][] noise) {
		int [][] ret = new int[s.sizex][s.sizey];
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				ret[x][y] = 0;
			}
		}
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				safeNoiseSet(ret, 2 * x, 2 * y, noise[x][y]);
				safeNoiseSet(ret, 2 * x + 1, 2 * y, noise[x][y]);
				safeNoiseSet(ret, 2 * x, 2 * y + 1, noise[x][y]);
				safeNoiseSet(ret, 2 * x + 1, 2 * y + 1, noise[x][y]);
			}
		}
		
		return ret;
	}
	
	private int[][] getSmoothNoiseTable(int[][] noise) {
		int[][] smooth = new int[s.sizex][s.sizey];
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				smooth[x][y] = 0;
			}
		}
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				double corners = (safeNoiseGet(noise, x-1, y-1)+safeNoiseGet(noise, x+1, y-1)+safeNoiseGet(noise, x-1, y+1)+safeNoiseGet(noise, x+1, y+1)) / 16;
				double sides = (safeNoiseGet(noise, x-1, y)+safeNoiseGet(noise, x+1, y)+safeNoiseGet(noise, x, y-1)+safeNoiseGet(noise, x, y+1)) / 8;
				double center = safeNoiseGet(noise, x, y) / 4;
				smooth[x][y] = (int)(corners + sides + center);
			}
		}
		
		return smooth;
	}
	
	private int[] findFirstPoint(boolean[][] aShape) {
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				if(aShape[x][y]) {
					int[] ret = new int[2];
					ret[0] = x;
					ret[1] = y;
					return ret;
				}
			}
		}
		return null;
	}
	
	private int[][] buildNilShape() {
		int[][] ret = new int[s.sizex][s.sizey];
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				ret[x][y] = -1;
			}
		}
		
		return ret;
	}
	
	private boolean[][] convert3ValuesShape(int[][] aShape) {
		boolean[][] ret = new boolean[s.sizex][s.sizey];
		
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				ret[x][y] = (aShape[x][y]==1);
			}
		}
		
		return ret;		
	}
	
	private boolean[][] substractShape(boolean[][] fromShape, boolean[][] subShape) {
		for(int x=0; x<s.sizex; x++) {
			for(int y=0; y<s.sizey; y++) {
				if(fromShape[x][y] && subShape[x][y]) {
					fromShape[x][y] = false;
				}
			}
		}
		return fromShape;
	}
	
	private void getWholeShape(int[][] currChunk, boolean[][] mapShape, int x, int y) {
		if(x>=0 && y>=0 && x<s.sizex && y<s.sizey) {
			if(currChunk[x][y] != -1) {
				return;
			}
			currChunk[x][y] = 0;
			if(mapShape[x][y]) {
				currChunk[x][y] = 1;
				getWholeShape(currChunk, mapShape, x - 1, y - 1);
				getWholeShape(currChunk, mapShape, x - 1, y);
				getWholeShape(currChunk, mapShape, x - 1, y + 1);
				getWholeShape(currChunk, mapShape, x, y - 1);
				getWholeShape(currChunk, mapShape, x, y + 1);
				getWholeShape(currChunk, mapShape, x + 1, y - 1);
				getWholeShape(currChunk, mapShape, x + 1, y);
				getWholeShape(currChunk, mapShape, x + 1, y + 1);				
			}
		}
	}

	private List<boolean[][]> divideIntoWholeShapes(boolean[][] shape) {
		boolean[][] leftOver = shape;
		List<boolean[][]> chunks = new ArrayList<boolean[][]>();
		while((new Shape(s.sizex, s.sizey, leftOver)).getWeight() > 0) {
			int[] coord = findFirstPoint(leftOver);
			int[][] chunk = buildNilShape();
			getWholeShape(chunk, leftOver, coord[0], coord[1]);
			boolean[][] bChunk = convert3ValuesShape(chunk);
			chunks.add(bChunk);
			leftOver = substractShape(leftOver, bChunk);
		}
		return chunks;
	}
	
	private boolean[][] cutOffLooseFragments(boolean[][] aShape) {
		List<boolean[][]> chunks = divideIntoWholeShapes(aShape);
		int maxWeight = 0;
		boolean[][] maxChunk = aShape;
		for(boolean[][] chunk : chunks) {
			int chunkWeight = (new Shape(s.sizex, s.sizey, chunk)).getWeight();
			if(chunkWeight > maxWeight) {
				maxChunk = chunk;
				maxWeight = chunkWeight;
			}
		}
		return maxChunk;
	}

	private boolean failBeautyStats() {
		int w = s.getWeight();
		int a = s.sizex * s.sizey;
		return(w <= 6 || (w >= 7 && w <= 12 && a >= 4 * w));
	}	

}
