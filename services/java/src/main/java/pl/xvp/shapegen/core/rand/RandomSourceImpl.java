package pl.xvp.shapegen.core.rand;

import java.util.Random;

public class RandomSourceImpl implements RandomSource {

	private Random random;

	//TODO remove duplication with Clouds class
	//TODO use both this and non-random stub version
	public RandomSourceImpl() {
		random = new Random(System.currentTimeMillis());
	}

	public int getRand(int n) {
		return random.nextInt(n);
	}

}
